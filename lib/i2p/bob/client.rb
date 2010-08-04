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
  # @see http://www.i2p2.de/applications.html
  # @see http://bob.i2p.to/bridge.html
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

      unless block_given?
        client
      else
        begin
          result = block.call(client)
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

      block.call(self) if block_given?
    end

    ##
    # Returns `true` if a connection to the BOB bridge has been established
    # and is active.
    #
    # @example
    #   bob.connected?             #=> true
    #   bob.disconnect
    #   bob.connected?             #=> false
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
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
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
      send_line(:quit)
      read_line # "OK Bye!"
      disconnect
    end

  protected

    ##
    # Sends a command line over the BOB bridge socket.
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
    # Reads a response line from the BOB bridge socket.
    #
    # @return [String]
    def read_line
      line = @socket.readline.chomp
      warn "<- #{line}" if @options[:debug]
      line
    end
  end
end; end
