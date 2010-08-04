require 'pathname'
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

##
# @example Checking whether an I2P router is running locally
#   I2P.available?      #=> true, if the I2P router is installed
#   I2P.running?        #=> true, if the I2P router is running
#
# @example Starting and stopping the local I2P router daemon
#   I2P.start!          #=> executes `i2prouter start`
#   I2P.restart!        #=> executes `i2prouter restart`
#   I2P.stop!           #=> executes `i2prouter stop`
#
# @see http://www.i2p2.de/download.html
module I2P
  autoload :Hosts,   'i2p/hosts'
  autoload :Key,     'i2p/key'
  autoload :BOB,     'i2p/bob'
  autoload :SAM,     'i2p/sam'
  autoload :VERSION, 'i2p/version'

  # The path used to locate the `i2prouter` executable.
  PATH = (ENV['I2P_PATH'] || ENV['PATH']).split(File::PATH_SEPARATOR) unless defined?(PATH)

  ##
  # Returns `true` if I2P is available, `false` otherwise.
  #
  # This attempts to locate the `i2prouter` executable in the user's current
  # `PATH` environment.
  #
  # @example
  #   I2P.available?    #=> true
  #
  # @return [Boolean]
  def self.available?
    !!program_path
  end

  ##
  # Returns `true` if the I2P router is running locally, `false` otherwise.
  #
  # This first attempts to call `i2prouter status` if the executable can be
  # located in the user's current `PATH` environment, falling back to
  # attempting to establish a Simple Anonymous Messaging (SAM) protocol
  # connection to the standard SAM port 7656 on `localhost`.
  #
  # If I2P isn't in the `PATH` and hasn't been configured with SAM enabled,
  # this will return `false` regardless of whether I2P actually is running
  # or not.
  #
  # @example
  #   I2P.running?      #=> false
  #
  # @return [Boolean]
  def self.running?
    if available?
      /is running/ === `#{program_path} status`.chomp
    else
      begin
        I2P::SAM::Client.open.disconnect
        true
      rescue Errno::ECONNREFUSED
        false
      end
    end
  end

  ##
  # Starts the local I2P router daemon.
  #
  # Returns the process identifier (PID) if the I2P router daemon was
  # successfully started, `nil` otherwise.
  #
  # This relies on being able to execute `i2prouter start`, which requires
  # the `i2prouter` executable to be located in the user's current `PATH`
  # environment.
  #
  # @return [Integer]
  # @since  0.1.1
  def self.start!
    if available?
      `#{program_path} start` unless running?
      `#{program_path} status` =~ /is running \((\d+)\)/ ? $1.to_i : nil
    end
  end

  ##
  # Restarts the local I2P router daemon, starting it in case it wasn't
  # already running.
  #
  # Returns `true` if the I2P router daemon was successfully restarted,
  # `false` otherwise.
  #
  # This relies on being able to execute `i2prouter restart`, which requires
  # the `i2prouter` executable to be located in the user's current `PATH`
  # environment.
  #
  # @return [Boolean]
  # @since  0.1.1
  def self.restart!
    if available?
      /Starting I2P Service/ === `#{program_path} restart`
    end
  end

  ##
  # Stops the local I2P router daemon.
  #
  # Returns `true` if the I2P router daemon was successfully shut down,
  # `false` otherwise.
  #
  # This relies on being able to execute `i2prouter stop`, which requires
  # the `i2prouter` executable to be located in the user's current `PATH`
  # environment.
  #
  # @return [Boolean]
  # @since  0.1.1
  def self.stop!
    if available?
      /Stopped I2P Service/ === `#{program_path} stop`
    end
  end

  ##
  # Returns the path to the `i2prouter` executable.
  #
  # Returns `nil` if the program could not be located in any of the
  # directories denoted by the user's current `I2P_PATH` or `PATH`
  # environment variables.
  #
  # @example
  #   I2P.program_path  #=> "/opt/local/bin/i2prouter"
  #
  # @param  [String, #to_s] program_name
  # @return [Pathname]
  def self.program_path(program_name = :i2prouter)
    program_name = program_name.to_s
    @program_paths ||= {}
    @program_paths[program_name] ||= begin
      PATH.find do |dir|
        if File.executable?(file = File.join(dir, program_name))
          break Pathname(file)
        end
      end
    end
  end
end
