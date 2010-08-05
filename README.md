I2P.rb: Anonymous Networking for Ruby
=====================================

This is a Ruby library for interacting with the [I2P][] anonymity network.

* <http://github.com/bendiken/i2p-ruby>

Features
--------

* Supports checking whether I2P is installed in the user's current `PATH`
  and whether the I2P router is currently running.
* Supports starting, restarting and stopping the I2P router daemon.
* Implements the basics of the [I2P Simple Anonymous Messaging (SAM)][SAM]
  protocol.
* Supports I2P name resolution using both `hosts.txt` as well as SAM.
* Compatible with Ruby 1.8.7+, Ruby 1.9.x, and JRuby 1.4/1.5.
* Bundles the I2P 0.8 [SDK][] and [Streaming Library][Streaming] for use
  with [JRuby][],

Examples
--------

    require 'rubygems'
    require 'i2p'

### Checking whether an I2P router is running locally

    I2P.available?      #=> true, if the I2P router is installed
    I2P.running?        #=> true, if the I2P router is running

### Starting and stopping the local I2P router daemon

    I2P.start!          #=> executes `i2prouter start`
    I2P.restart!        #=> executes `i2prouter restart`
    I2P.stop!           #=> executes `i2prouter stop`

### Looking up the public key for an I2P name from hosts.txt

    puts I2P::Hosts["forum.i2p"].to_base64

### Looking up the public key for an I2P name using SAM

    I2P::SAM::Client.open(:port => 7656) do |sam|
      puts sam.lookup_name("forum.i2p").to_base64
    end

### Generating a new key pair and I2P destination using SAM

    I2P::SAM::Client.open(:port => 7656) do |sam|
      key_pair = sam.generate_destination
      puts key_pair.destination.to_base64
    end

### Using the I2P SDK and Streaming Library directly from JRuby

I2P.rb bundles the public-domain [I2P SDK][SDK] (`i2p/sdk.jar`) and
[Streaming Library][Streaming] (`i2p/streaming.jar`) archives, which means
that to [script][JRuby howto] the I2P Java client implementation from
[JRuby][], you need only require these two files as follows:

    require 'i2p/sdk.jar'
    require 'i2p/streaming.jar'

Documentation
-------------

* <http://cypherpunk.rubyforge.org/i2p/>

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [I2P](http://www.i2p2.de/download.html) (>= 0.8)

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of I2P.rb, do:

    % [sudo] gem install i2p                 # Ruby 1.8.7+ or 1.9.x
    % [sudo] gem install backports i2p       # Ruby 1.8.1+

Environment
-----------

The following are the default values for environment variables that let
you customize I2P.rb's implicit configuration:

    $ export I2P_PATH=$PATH
    $ export I2P_BOB_HOST=127.0.0.1
    $ export I2P_BOB_PORT=2827
    $ export I2P_SAM_HOST=127.0.0.1
    $ export I2P_SAM_PORT=7656

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/i2p-ruby.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/bendiken/i2p-ruby/tarball/master

Author
------

* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

License
-------

I2P.rb is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.

[I2P]:         http://www.i2p2.de/
[SDK]:         http://www.i2p2.de/package-client.html
[Streaming]:   http://www.i2p2.de/package-streaming.html
[SAM]:         http://www.i2p2.de/samv3.html
[BOB]:         http://bob.i2p.to/bridge.htm
[JRuby]:       http://jruby.org/
[JRuby howto]: http://kenai.com/projects/jruby/pages/CallingJavaFromJRuby
[Backports]:   http://rubygems.org/gems/backports
