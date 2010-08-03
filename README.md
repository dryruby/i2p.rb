I2P.rb: Anonymous Networking for Ruby
=====================================

This is a Ruby library for interacting with the [I2P][] anonymity network.

* <http://github.com/bendiken/i2p-ruby>

Features
--------

* Supports checking whether I2P is installed in the user's current `PATH`,
  and whether it is currently running.
* Implements the basics of the [I2P Simple Anonymous Messaging (SAM)][SAM]
  protocol.
* Compatible with Ruby 1.8.7+, Ruby 1.9.x, and JRuby 1.4/1.5.

Examples
--------

    require 'rubygems'
    require 'i2p'

### Checking whether an I2P router is running locally

    I2P.running?        #=> true

### Generating a new key pair and I2P destination

    I2P::SAM::Client.open(:port => 7656) do |sam|
      private_key, public_key = sam.generate_destination
      puts "PRIVATE KEY:\n#{private_key}"
      puts "PUBLIC KEY:\n#{public_key}"
    end

### Looking up the public key for an I2P name

    I2P::SAM::Client.open(:port => 7656) do |sam|
      puts sam.lookup_name("forum.i2p").to_s
    end

Documentation
-------------

* <http://cypherpunk.rubyforge.org/i2p/>

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [I2P](http://www.i2p2.de/download.html) (>= 0.7.3)

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

[I2P]:       http://www.i2p2.de/
[SAM]:       http://www.i2p2.de/samv3.html
[Backports]: http://rubygems.org/gems/backports
