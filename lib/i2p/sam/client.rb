module I2P; module SAM
  ##
  # **I2P Simple Anonymous Messaging (SAM) V3 client.**
  #
  # @example Connecting to the I2P SAM bridge (1)
  #   sam = I2P::SAM::Client.new(:port => 7656)
  #
  # @example Connecting to the I2P SAM bridge (2)
  #   I2P::SAM::Client.open(:port => 7656) do |sam|
  #     ...
  #   end
  #
  # @see http://www.i2p2.de/applications.html
  # @see http://www.i2p2.de/samv3.html
  class Client
    ##
    # Establishes a connection to the SAM bridge.
    #
    # @example Connecting to the default port
    #   sam = I2P::SAM::Client.open
    #
    # @example Connecting to the given port
    #   sam = I2P::SAM::Client.open(:port => 7656)
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [String, #to_s]  :host    (DEFAULT_HOST)
    # @option options [Integer, #to_i] :port    (DEFAULT_PORT)
    # @option options [Integer, #to_i] :version (PROTOCOL_VERSION)
    # @yield  [client]
    # @yieldparam [Client] client
    # @return [void]
    def self.open(options = {}, &block)
      client = self.new(options)
      client.connect.hello # handshake

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
    # Returns the socket connection to the SAM bridge.
    #
    # @return [TCPSocket]
    attr_reader :socket

    ##
    # Initializes a new client instance.
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [String, #to_s]  :host    (DEFAULT_HOST)
    # @option options [Integer, #to_i] :port    (DEFAULT_PORT)
    # @option options [Integer, #to_i] :version (PROTOCOL_VERSION)
    # @yield  [client]
    # @yieldparam [Client] client
    def initialize(options = {}, &block)
      @options = options.dup
      @host    = (@options.delete(:host)    || DEFAULT_HOST).to_s
      @port    = (@options.delete(:port)    || DEFAULT_PORT).to_i
      @version = (@options.delete(:version) || PROTOCOL_VERSION).to_i

      block.call(self) if block_given?
    end

    ##
    # Returns `true` if a connection to the SAM bridge has been established
    # and is active.
    #
    # @example
    #   sam.connected?             #=> true
    #   sam.disconnect
    #   sam.connected?             #=> false
    #
    # @return [Boolean]
    def connected?
      !!@socket
    end

    ##
    # Establishes a connection to the SAM bridge.
    #
    # If called after the connection has already been established,
    # disconnects and then reconnects to the bridge.
    #
    # @example
    #   sam.connect
    #
    # @return [void]
    def connect
      disconnect if connected?
      @socket = TCPSocket.new(@host, @port)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
      self
    end
    alias_method :reconnect, :connect

    ##
    # Closes the connection to the SAM bridge.
    #
    # If called after the connection has already been closed, does nothing.
    #
    # @example
    #   sam.disconnect
    #
    # @return [void]
    def disconnect
      @socket.close if @socket && !@socket.closed?
      @socket = nil
      self
    end
    alias_method :close, :disconnect

    ##
    # Performs the SAM protocol handshake and returns the autonegotiated
    # protocol version.
    #
    # @example
    #   sam.hello                            #=> 3.0
    #
    # @example
    #   sam.hello(:min => 3.0, :max => 4.0)  #=> 3.0
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [Float, #to_f]   :min (PROTOCOL_VERSION)
    # @option options [Float, #to_f]   :max (PROTOCOL_VERSION)
    # @return [Float]
    # @raise  [ProtocolNotSupported] if the handshake failed
    def hello(options = {})
      send_msg(:hello, :version, {
        :min => '%.1f' % (options[:min] || @version).to_f,
        :max => '%.1f' % (options[:max] || @version).to_f,
      })
      read_reply[:version].to_f
    end

    ##
    # Returns the public key of the I2P destination corresponding to `name`.
    #
    # @example
    #   sam.lookup_name("forum.i2p")         #=> #<I2P::PublicKey:...>
    #
    # @param  [String, #to_s] name
    # @return [PublicKey]
    # @raise  [Error::KeyNotFound] if `name` was not found
    def lookup_name(name)
      send_msg(:naming, :lookup, :name => name.to_s)
      PublicKey.parse(read_reply[:value])
    end

    ##
    # Generates a new I2P destination and returns the asymmetric key pair
    # for it.
    #
    # @example
    #   private_key, public_key = sam.generate_dest
    #
    # @return [Array(PrivateKey, PublicKey)]
    def generate_dest
      send_msg(:dest, :generate)
      keys = read_reply
      [PrivateKey.parse(keys[:priv]), PublicKey.parse(keys[:pub])]
    end
    alias_method :generate_destination, :generate_dest

  protected

    ##
    # Sends a message to the SAM bridge.
    #
    # @param  [Symbol, #to_s]          noun
    # @param  [Symbol, #to_s]          verb
    # @param  [Hash{Symbol => Object}] options
    # @return [void]
    def send_msg(noun, verb, options = {})
      msg = [noun.to_s.upcase, verb.to_s.upcase]
      msg += options.map { |k, v| "#{k.to_s.upcase}=#{v}" } unless options.empty?
      send_line(msg.join(' '))
      self
    end

    ##
    # Sends a text line over the SAM bridge socket.
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
    # Reads a reply line from the SAM bridge socket.
    #
    # @return [String]
    def read_reply
      reply = @socket.readline.chomp
      warn "<- #{reply}" if @options[:debug]
      case reply
        when /^HELLO REPLY RESULT=OK VERSION=(\S*)/
          {:version => $1}
        when /^HELLO REPLY RESULT=NOVERSION/
          raise Error::ProtocolNotSupported.new("SAM bridge does not support the requested protocol version")
        when /^HELLO REPLY RESULT=I2P_ERROR MESSAGE="([^"]+)"/
          raise Error.new($1.strip)
        when /^NAMING REPLY RESULT=OK NAME=(\S+) VALUE=(\S+)/
          {:name => $1, :value => $2}
        when /^NAMING REPLY RESULT=INVALID_KEY NAME=(\S+)/
          raise Error::KeyNotValid.new($1)
        when /^NAMING REPLY RESULT=KEY_NOT_FOUND NAME=(\S+)/
          raise Error::KeyNotFound.new($1)
        when /^DEST REPLY PUB=(\S+) PRIV=(\S+)/
          {:pub => $1, :priv => $2}
        else
          raise Error.new(reply)
      end
    end
  end
end; end
