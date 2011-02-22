# eagle

eagle is a lightweight looking glass I've written to interface birdc.

I wrote this so I could do faster lookups, and at the prodding of dotwaffle.

## Configuration

Very little. This assumes that your BIRD socket file is /var/run/bird.ctl.

I promise I'll add a socket configuration parameter or something in the future.

Other parameters can be found in config.yml.

## Installation

You need the following gems and their dependencies:
- sinatra
- json
- net/dns/resolver

git clone this repo into a directory of your choosing, update the path (chdir), IP address, and port in config.yml, and run 'rake start'.


Drop me a line via e-mail, Twitter (@oogali), or IRC.
