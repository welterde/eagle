# eagle

eagle is an extremely skinny "looking glass" I've written to interface with [BIRD].
(It only does IPv4 BGP lookups, can it get any more skinny?)

I wrote this so I could close a Terminal window, and with some motivation by [@dotwaffle].

## Installation

You need the following gems (and their dependencies):

    sinatra
    json
    net-dns

git clone this repo into a directory of your choosing, update the path (chdir), IP address, and port in config.yml, and run 'rake start'.

Looks something like:

    git clone https://oogali@github.com/oogali/eagle.git
    cd eagle
    vi config.yml
    rake start

## Configuration

Very little. This assumes that your BIRD socket file is /var/run/bird.ctl.

I promise I'll add a socket configuration parameter or something in the future.

Other parameters can be found in config.yml.

## More Information

Any other questions, drop me a line via e-mail, Twitter ([@oogali]), or IRC.

*Easter egg or whatever you call it:* If you send a GET request to /lookup (/lookup?prefix=1.2.3.4), you'll get a JSON object that you can do stuff with.

    roadrunner:eagle oogali$ curl -si eng:8180/lookup?prefix=69.60.134.179
    HTTP/1.1 200 OK
    Content-Type: text/html;charset=utf-8
    Content-Length: 1582
    Connection: keep-alive
    Server: thin 1.2.5 codename This Is Not A Web Server
    
    [
      {
        "med": 20,
        "prefix": "69.60.128.0/20",
        "localpref": 200,
        "aspath": [
          8001,
          23131
        ],
        "nexthop": "74.122.175.242",
        "origin_as": 23131,
        "best": true,
        "received": "Feb19",
        "interface": "eth0",
        "cluster": [
          "74.122.175.244"
        ],
        "origin": "igp",
        "unicast": true,
        "originator_id": "208.81.85.234",
        "router_id": "74.122.175.244",
        "gateway": "38.105.144.1",
        "communities": [
          "8001:4000",
          "8001:4001",
          "18559:200",
          "18559:202",
          "18559:502"
        ],
        "config_name": "cr1_ewr1"
      },
      {
        "med": 20,
        "prefix": "69.60.128.0/20",
        "localpref": 200,
        "aspath": [
          8001,
          23131
        ],
        "nexthop": "74.122.175.242",
        "origin_as": 23131,
        "best": false,
        "received": "Feb19",
        "interface": "eth0",
        "cluster": [
          "74.122.175.248"
        ],
        "origin": "igp",
        "unicast": true,
        "originator_id": "208.81.85.234",
        "router_id": "74.122.175.248",
        "gateway": "38.105.144.1",
        "config_name": "cr2_ewr1"
      },
      {
        "med": 50,
        "prefix": "69.60.128.0/20",
        "localpref": 200,
        "aspath": [
          8001,
          23131
        ],
        "nexthop": "198.32.118.157",
        "origin_as": 23131,
        "best": false,
        "received": "Feb19",
        "interface": "eth0",
        "origin": "igp",
        "unicast": true,
        "router_id": "74.122.175.242",
        "gateway": "38.105.144.1",
        "communities": [
          "8001:4000",
          "8001:4001",
          "18559:200",
          "18559:202",
          "18559:502"
        ],
        "config_name": "cr1_nyc2"
      }
    ]

[BIRD]: http://bird.network.cz/
[@dotwaffle]: http://twitter.com/dotwaffle
[@oogali]: http://twitter.com/oogali
