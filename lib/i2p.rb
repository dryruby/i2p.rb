if RUBY_VERSION < '1.8.7'
  # @see http://rubygems.org/gems/backports
  begin
    require 'backports/1.8.7'
  rescue LoadError
    begin
      require 'rubygems'
      require 'backports/1.8.7'
    rescue LoadError
      abort "I2P.rb requires Ruby 1.8.7 or the Backports gem (hint: `gem install backports')."
    end
  end
end

module I2P
  autoload :Key,     'i2p/key'
  autoload :VERSION, 'i2p/version'
end
