module I2P; module BOB
  ##
  # **I2P Basic Open Bridge (BOB) client.**
  #
  # @example Connecting to the I2P BOB bridge (1)
  #   bob = I2P::BOB::Client.new(:port => 2827)
  #
  # @example Connecting to the I2P BOB bridge (2)
  #   I2P::BOB::Client.open(:port => 2827) do |bob|
  #     ...
  #   end
  #
  # @example Generating a new destination
  #   I2P::BOB::Client.open(:nickname => :foo) do |bob|
  #     bob.newkeys
  #   end
  #
  # @example Generating a new key pair
  #   I2P::BOB::Client.open(:nickname => :foo) do |bob|
  #     bob.newkeys
  #     bob.getkeys
  #   end
  #
  # @see   http://www.i2p2.de/applications.html
  # @see   http://bob.i2p.to/bridge.html
  # @since 0.1.4
  class Client
    ##
    # Establishes a connection to the BOB bridge.
    #
    # @example Connecting to the default port
    #   bob = I2P::BOB::Client.open
    #
    # @example Connecting to the given port
    #   bob = I2P::BOB::Client.open(:port => 2827)
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [String, #to_s]  :host    (DEFAULT_HOST)
    # @option options [Integer, #to_i] :port    (DEFAULT_PORT)
    # @yield  [client]
    # @yieldparam [Client] client
    # @return [void]
    def self.open(options = {}, &block)
      client = self.new(options)
      client.connect

      if options[:nickname]
        begin
          client.getnick(options[:nickname])
        rescue Error => e
          client.setnick(options[:nickname])
        end
      end

      client.setkeys(options[:keys])     if options[:keys]
      client.quiet(options[:quiet])      if options[:quiet]
      client.inhost(options[:inhost])    if options[:inhost]
      client.inport(options[:inport])    if options[:inport]
      client.outhost(options[:outhost])  if options[:outhost]
      client.outport(options[:outport])  if options[:outport]

      unless block_given?
        client
      else
        begin
          result = case block.arity
            when 1 then block.call(client)
            else client.instance_eval(&block)
          end
        ensure
          client.disconnect
        end
        result
      end
    end

    ##
    # Returns the socket connection to the BOB bridge.
    #
    # @return [TCPSocket]
    attr_reader :socket

    ##
    # Returns the host name or IP address of the BOB bridge.
    #
    # @return [String]
    attr_reader :host

    ##
    # Returns the port number of the BOB bridge.
    #
    # @return [Integer]
    attr_reader :port

    ##
    # Initializes a new client instance.
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [String, #to_s]  :host    (DEFAULT_HOST)
    # @option options [Integer, #to_i] :port    (DEFAULT_PORT)
    # @yield  [client]
    # @yieldparam [Client] client
    def initialize(options = {}, &block)
      @options = options.dup
      @host    = (@options.delete(:host) || DEFAULT_HOST).to_s
      @port    = (@options.delete(:port) || DEFAULT_PORT).to_i

      if block_given?
        case block.arity
          when 1 then block.call(self)
          else instance_eval(&block)
        end
      end
    end

    ##
    # Returns `true` if a connection to the BOB bridge has been established
    # and is active.
    #
    # @example
    #   bob.connected?                       #=> true
    #   bob.disconnect
    #   bob.connected?                       #=> false
    #
    # @return [Boolean]
    def connected?
      !!@socket
    end

    ##
    # Establishes a connection to the BOB bridge.
    #
    # If called after the connection has already been established,
    # disconnects and then reconnects to the bridge.
    #
    # @example
    #   bob.connect
    #
    # @return [void]
    def connect
      disconnect if connected?
      @socket = TCPSocket.new(@host, @port)
      @socket.setsockopt(::Socket::SOL_SOCKET, ::Socket::SO_KEEPALIVE, true)
      read_line # "BOB 00.00.0D"
      read_line # "OK"
      self
    end
    alias_method :reconnect, :connect

    ##
    # Closes the connection to the BOB bridge.
    #
    # If called after the connection has already been closed, does nothing.
    #
    # @example
    #   bob.disconnect
    #
    # @return [void]
    def disconnect
      @socket.close if @socket && !@socket.closed?
      @socket = nil
      self
    end
    alias_method :close, :disconnect

    ##
    # Closes the connection to the BOB bridge cleanly.
    #
    # @example
    #   bob.quit
    #
    # @return [void]
    def quit
      send_command(:quit)
      read_response # "Bye!"
      disconnect
    end
    alias_method :quit!, :quit

    ##
    # Verifies a Base64-formatted key pair or destination, returning `true`
    # for valid input.
    #
    # @example
    #   bob.verify("foobar")                 #=> false
    #   bob.verify(I2P::Hosts["forum.i2p"])  #=> true
    #
    # @param  [#to_base64, #to_s] data
    # @return [Boolean]
    def verify(data)
      send_command(:verify, data.respond_to?(:to_base64) ? data.to_base64 : data.to_s)
      read_response rescue false
    end

    ##
    # Creates a new tunnel with the given nickname.
    #
    # @example
    #   bob.setnick(:foo)
    #
    # @param  [String, #to_s] nickname
    # @return [void]
    def setnick(nickname)
      send_command(:setnick, @options[:nickname] = nickname.to_s)
      read_response # "Nickname set to #{nickname}"
      self
    end
    alias_method :nickname=, :setnick

    ##
    # Selects an existing tunnel with the given nickname.
    #
    # @example
    #   bob.getnick(:foo)
    #
    # @param  [String, #to_s] nickname
    # @return [void]
    def getnick(nickname)
      send_command(:getnick, @options[:nickname] = nickname.to_s)
      read_response # "Nickname set to #{nickname}"
      self
    end

    ##
    # Generates a new keypair for the current tunnel.
    #
    # @example
    #   bob.newkeys
    #
    # @return [Destination]
    def newkeys
      send_command(:newkeys)
      Destination.parse(read_response)
    end

    ##
    # Returns the destination for the current tunnel.
    #
    # @example
    #   bob.getdest
    #
    # @return [Destination]
    # @raise  [Error] if no tunnel has been selected
    def getdest
      send_command(:getdest)
      Destination.parse(read_response)
    end

    ##
    # Returns the key pair for the current tunnel.
    #
    # @example
    #   bob.getkeys
    #
    # @return [KeyPair]
    # @raise  [Error] if no public key has been set
    def getkeys
      send_command(:getkeys)
      KeyPair.parse(read_response)
    end

    ##
    # Sets the key pair for the current tunnel.
    #
    # @example
    #   bob.setkeys(I2P::KeyPair.parse("..."))
    #
    # @param  [KeyPair, #to_s] key_pair
    # @return [void]
    # @raise  [Error] if no tunnel has been selected
    def setkeys(key_pair)
      send_command(:setkeys, @options[:keys] = key_pair.respond_to?(:to_base64) ? key_pair.to_base64 : key_pair.to_s)
      read_response # the Base64-encoded destination
      self
    end
    alias_method :keys=, :setkeys

    ##
    # Sets the inbound host name or IP address that the current tunnel
    # listens on.
    #
    # The default for new tunnels is `inhost("localhost")`.
    #
    # @example
    #   bob.inhost('127.0.0.1')
    #
    # @param  [String, #to_s] host
    # @return [void]
    # @raise  [Error] if no tunnel has been selected
    def inhost(host)
      send_command(:inhost, @options[:inhost] = host.to_s)
      read_response # "inhost set"
      self
    end
    alias_method :inhost=, :inhost

    ##
    # Sets the inbound port number that the current tunnel listens on.
    #
    # @example
    #   bob.inport(37337)
    #
    # @param  [Integer, #to_i] port
    # @return [void]
    # @raise  [Error] if no tunnel has been selected
    def inport(port)
      send_command(:inport, @options[:inport] = port.to_i)
      read_response # "inbound port set"
      self
    end
    alias_method :inport=, :inport

    ##
    # Sets the outbound host name or IP address that the current tunnel
    # connects to.
    #
    # The default for new tunnels is `outhost("localhost")`.
    #
    # @example
    #   bob.outhost('127.0.0.1')
    #
    # @param  [String, #to_s] host
    # @return [void]
    # @raise  [Error] if no tunnel has been selected
    def outhost(host)
      send_command(:outhost, @options[:outhost] = host.to_s)
      read_response # "outhost set"
      self
    end
    alias_method :outhost=, :outhost

    ##
    # Sets the outbound port number that the current tunnel connects to.
    #
    # @example
    #   bob.outport(80)
    #
    # @param  [Integer, #to_i] port
    # @return [void]
    # @raise  [Error] if no tunnel has been selected
    def outport(port)
      send_command(:outport, @options[:output] = port.to_i)
      read_response # "outbound port set"
      self
    end
    alias_method :outport=, :outport

    ##
    # Toggles whether to send the incoming destination key to listening
    # sockets.
    #
    # This only applies to outbound tunnels and has no effect on inbound
    # tunnels.
    #
    # The default for new tunnels is `quiet(false)`.
    #
    # @example Enabling quiet mode
    #   bob.quiet
    #   bob.quiet(true)
    #   bob.quiet = true
    #
    # @example Disabling quiet mode
    #   bob.quiet(false)
    #   bob.quiet = false
    #
    # @param  [Boolean] value
    # @return [void]
    # @raise  [Error] if no tunnel has been selected
    def quiet(value = true)
      send_command(:quiet, @options[:quiet] = value.to_s)
      read_response # "Quiet set"
      self
    end
    alias_method :quiet=, :quiet

    ##
    # Sets an I2P Control Protocol (I2CP) option for the current tunnel.
    #
    # @example
    #   bob.option(key, value)
    #
    # @param  [String, #to_s] key
    # @param  [String, #to_s] value
    # @return [void]
    # @raise  [Error] if no tunnel has been selected
    def option(key, value)
      send_command(:option, [key, value].join('='))
      read_response # "#{key} set to #{value}"
      self
    end

    ##
    # Starts and activates the current tunnel.
    #
    # @example
    #   bob.start
    #
    # @return [void]
    # @raise  [Error] if the tunnel settings are incomplete
    # @raise  [Error] if the tunnel is already active
    def start
      send_command(:start)
      read_response # "tunnel starting"
      self
    end
    alias_method :start!, :start

    ##
    # Stops and inactivates the current tunnel.
    #
    # @example
    #   bob.stop
    #
    # @return [void]
    # @raise  [Error] if no tunnel has been selected
    # @raise  [Error] if the tunnel is already inactive
    def stop
      send_command(:stop)
      read_response # "tunnel stopping"
      self
    end
    alias_method :stop!, :stop

    ##
    # Removes the current tunnel. The tunnel must be inactive.
    #
    # @example
    #   bob.clear
    #
    # @return [void]
    # @raise  [Error] if no tunnel has been selected
    # @raise  [Error] if the tunnel is still active
    def clear
      send_command(:clear)
      read_response # "cleared"
      self
    end
    alias_method :clear!, :clear

  protected

    ##
    # Sends a command over the BOB bridge socket.
    #
    # @param  [String, #to_s] command
    # @param  [Array<#to_s>]  args
    # @return [void]
    def send_command(command, *args)
      send_line([command.to_s, *args].join(' '))
    end

    ##
    # Sends a text line over the BOB bridge socket.
    #
    # @param  [String, #to_s] line
    # @return [void]
    def send_line(line)
      connect unless connected?
      warn "-> #{line}" if @options[:debug]
      @socket.write(line.to_s + "\n")
      @socket.flush
      self
    end

    ##
    # Reads a response from the BOB bridge socket.
    #
    # @return [Object]
    # @raise  [Error] on an ERROR response
    def read_response
      case line = read_line
        when 'OK'             then true
        when /^OK\s*(.*)$/    then $1.strip
        when /^ERROR\s+(.*)$/ then raise Error.new($1.strip)
        else line
      end
    end

    ##
    # Reads a text line from the BOB bridge socket.
    #
    # @return [String]
    def read_line
      line = @socket.readline.chomp
      warn "<- #{line}" if @options[:debug]
      line
    end
  end
end; end
