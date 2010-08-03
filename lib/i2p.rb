require 'socket'

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
  autoload :BOB,     'i2p/bob'
  autoload :SAM,     'i2p/sam'
  autoload :VERSION, 'i2p/version'

  ##
  # Returns `true` if the I2P router is running locally, `false` otherwise.
  #
  # This works by attempting to establish a Simple Anonymous Messaging (SAM)
  # protocol connection to the standard SAM port 7656 on `localhost`. If
  # I2P hasn't been configured with SAM enabled, this will return `false`.
  #
  # @example
  #   I2P.running?      #=> false
  #
  # @return [Boolean]
  def self.running?
    begin
      I2P::SAM::Client.new.disconnect
      true
    rescue Errno::ECONNREFUSED
      false
    end
  end

  ##
  # Returns `true` if I2P is available, `false` otherwise.
  #
  # This works by attempting to locate the `i2prouter` executable in the
  # user's current `PATH` environment.
  #
  # @example
  #   I2P.available?    #=> true
  #
  # @return [Boolean]
  def self.available?
    !!program_path
  end

  ##
  # Returns the path to the `i2prouter` executable, or `nil` if the program
  # could not be found in the user's current `PATH` environment.
  #
  # @example
  #   I2P.program_path  #=> "/opt/local/bin/i2prouter"
  #
  # @param  [String, #to_s] program_name
  # @return [String]
  def self.program_path(program_name = :i2prouter)
    (ENV['I2P_PATH'] || ENV['PATH']).split(File::PATH_SEPARATOR).each do |path|
      program_path = File.join(path, program_name.to_s)
      return program_path if File.executable?(program_path)
    end
    return nil
  end
end
