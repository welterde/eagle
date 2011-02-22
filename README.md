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

[BIRD]: http://bird.network.cz/
[@dotwaffle]: http://twitter.com/dotwaffle
[@oogali]: http://twitter.com/oogali
