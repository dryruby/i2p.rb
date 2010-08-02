I2P.rb: Anonymous Networking for Ruby
=====================================

This is a Ruby library for interacting with the [I2P][] anonymity network.

* <http://github.com/bendiken/i2p-ruby>

Features
--------

* Compatible with Ruby 1.8.7+, Ruby 1.9.x, and JRuby 1.4/1.5.

Examples
--------

    require 'rubygems'
    require 'i2p'

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
[Backports]: http://rubygems.org/gems/backports
