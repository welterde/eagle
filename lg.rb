require 'sinatra'
require 'haml'
require 'sass'

module Lg
  class Application < Sinatra::Base
    get '/' do
      haml :index
    end

    get '/lg.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass :lg
    end

    get '/lg.js' do
     File.read File.join('public', 'lg.js')
    end

    post '/lookup' do
    end
  end
end
