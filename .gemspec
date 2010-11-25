#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'i2p'
  gem.homepage           = 'http://cypherpunk.rubyforge.org/i2p/'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'Anonymous networking for Ruby.'
  gem.description        = 'I2P.rb is a Ruby library for interacting with the I2P anonymity network.'
  gem.rubyforge_project  = 'cypherpunk'

  gem.author             = 'Arto Bendiken'
  gem.email              = 'i2p@i2p.net'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CREDITS README UNLICENSE VERSION) + Dir.glob('lib/**/*.rb') + Dir.glob('lib/**/*.jar')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.1'
  gem.requirements               = ['I2P (>= 0.8)']
  gem.add_development_dependency 'yard',  '>= 0.6.0'
  gem.add_development_dependency 'rspec', '>= 1.3.0'
  gem.post_install_message       = nil
end
