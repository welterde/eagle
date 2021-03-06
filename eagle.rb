require 'sinatra'
require 'haml'
require 'sass'
require 'socket'
require 'json'
require 'net/dns/resolver'

module Eagle
  class Eagle
    # define birdc "prefix" codes
    BIRDC_EOF_CODE = '0000'
    BIRDC_PATH_CODE = '1007'
    BIRDC_TYPE_CODE = '1008'
    BIRDC_ATTR_CODE = '1012'
    BIRDC_ERROR_INVALID_IP_CODE = '9001'

    @sock = nil

    # Create a new object, socket path defaults to /var/run/bird.ctl
    def initialize(sockfile = '/var/run/bird.ctl')
      begin
        @sock = UNIXSocket.new sockfile
      rescue => error
        puts "Could not open socket #{sockfile}: #{error.to_s}"
        raise ArgumentError, error
      end
    end

    def find_prefix(addr)
      # send command to socket, loop up to 10 times reading data before giving up
      retries = 0
      data = String.new
      @sock.send "show route for #{addr} all\n", 0
      while !data.match(/(0000|9001) /) do
        rawdata = @sock.recvfrom(65536)
        data.concat rawdata[0]
        retries += 1
        break if retries >= 10
      end
      @sock.close

      # oops, we got something that wasn't an ip address
      raise(ArgumentError, "Invalid IP address") if data.match(/9001/)

      code = 0
      output = Hash.new

      # loop on each returned line
      data.split(/\n/).each do |line|
        # does this line start with a code? if so, reset continuation flag and store code
        m = line.match(/^(\d*)[ \-]*(.+)/)
        if m[1].length > 1
          continuation = false
          code = m[1]
        else
          continuation = true
        end

        # got our eof code, break out
        break if code == '0000'

        # create a new array for this code if none exists, then add this line to array
        output[code] = Array.new unless output.has_key? code
        if continuation
          output[code].last.concat m[2] + "\n"
        else
          output[code].push m[2] + "\n"
        end
      end

      # we didn't find any prefixes, give a null result
      return nil unless output[BIRDC_PATH_CODE]

      i = 0
      paths = Array.new
      prefix = nil

      # loop through each path
      output[BIRDC_PATH_CODE].each do |rawpath|
        # store prefix if we don't have it already
        prefix = rawpath.match(/^(\S+)\s+via/)[1] unless prefix

        # perform regex match on path line
        pathmatch = rawpath.match(/via\s+(\S+)\s+on\s+(\S+)\s+\[(\S+)\s+(\S+)\s+from\s+(\S+)\]\s+([\* ]*)\(\d+\)\s+\[(\w*)(\S)\]/)
        next unless pathmatch

        # save our path parameters into a nice little hash
        path = Hash.new
        path['prefix'] = prefix
        path['gateway'] = pathmatch[1]
        path['interface'] = pathmatch[2]
        path['config_name'] = pathmatch[3]
        path['received'] = pathmatch[4]
        path['router_id'] = pathmatch[5]
        path['best'] = !pathmatch[6].match(/\*/).nil?
        path['origin_as'] = pathmatch[7].sub('AS', '').to_i

        # save type value
        path['unicast'] = true if output[BIRDC_TYPE_CODE][i].match(/unicast/)

        # save each attribute
        output[BIRDC_ATTR_CODE][i].split(/\n/).each do |attr|
          case attr
            when /BGP.origin:\s+(.+)/
              path['origin'] = $~[1].downcase
            when /BGP.next_hop:\s+(.+)/
              path['nexthop'] = $~[1]
            when /BGP.local_pref:\s+(\d+)/
              path['localpref'] = $~[1].to_i
            when /BGP.med:\s+(\d+)/
              path['med'] = $~[1].to_i
            when /BGP.originator_id:\s+(.+)/
              path['originator_id'] = $~[1]
            when /BGP.community:\s+(.+)/
              path['communities'] = $~[1].gsub(/[\(\)]/, '').gsub(/,/, ':').split(/\s+/)
            when /BGP.as_path:\s+(.+)/
              path['aspath'] = Array.new
              $~[1].split(/\s+/).each { |as| path['aspath'].push as.to_i }
            when /BGP.cluster_list:\s+(.+)/
              path['cluster'] = Array.new
              $~[1].split(/\s+/).each { |member| path['cluster'].push member }
          end
        end

        # add our path has to the array, and increment our index
        paths.push path
        i += 1
      end

      # return our array of hashes
      paths
    end
  end

  class WebApplication < Sinatra::Base
    helpers do
      # quick and dirty helper to resolve IP addresses
      def resolve_ip(ip)
        Net::DNS::Resolver.start(ip, Net::DNS::PTR).answer[0].to_s.split(/\s+/)[4].sub(/\.$/, '') rescue "no reverse DNS"
      end

      # init eagle class and perform lookup
      def lookup(prefix)
        nil unless eagle = Eagle.new rescue nil
        eagle.find_prefix prefix
      end

      # return array of a specific type
      def collect(prefix, type)
        collection = Array.new
        lookup.prefix.each do |prefix|
          collection.push prefix[type]
        end
        collection
      end
    end

    get '/' do
      haml :index
    end

    get '/eagle.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass :eagle
    end

    get '/eagle.js' do
      content_type 'text/javascript', :charset => 'utf-8'
     File.read File.join('public', 'eagle.js')
    end

    # XXX: need a proper error handler for class init failure
    #       and missing form parameters
    get '/lookup' do
      nil unless params[:prefix]
      JSON.pretty_generate lookup(params[:prefix])
    end

    post '/lookup' do
      # default to prefix lookup for now
      nil unless params[:data]

      # default to prefix lookup for now
      #if params[:action] == 'prefix'
        @paths = lookup params[:prefix]
        haml :prefixes
      #end
    end

    get %r{/lookup/(aspath|communities|localpref|nexthop|origin_as)} do
      nil unless params[:prefix]
      JSON.pretty_generate collect(params[:prefix], params[:captures].first).uniq
    end
  end
end
