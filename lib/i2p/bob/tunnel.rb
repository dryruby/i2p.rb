module I2P; module BOB
  ##
  # **I2P Basic Open Bridge (BOB) tunnel manager.**
  #
  # @example Creating and controlling a new tunnel
  #   I2P::BOB::Tunnel.new(...) do |tunnel|
  #     tunnel.start
  #     sleep 0.1 until tunnel.running?
  #     # ... code that uses the tunnel goes here ...
  #     tunnel.stop
  #   end
  #
  # @example Starting a new inbound I2P tunnel in one go
  #   I2P::BOB::Tunnel.start({
  #     :nickname => :inproxy,
  #     :inhost   => "127.0.0.1"
  #     :inport   => 12345, # unused port
  #   })
  #
  # @example Starting a new outbound I2P tunnel in one go
  #   I2P::BOB::Tunnel.start({
  #     :nickname => :myssh,
  #     :outhost  => "127.0.0.1",
  #     :outport  => 22,    # SSH port
  #   })
  #
  # @example Starting an existing tunnel
  #   I2P::BOB::Tunnel.start(:myssh)
  #
  # @example Obtaining the I2P destination for a tunnel
  #   tunnel = I2P::BOB::Tunnel.start(:mytunnel)
  #   tunnel.destination  #=> #<I2P::Destination:...>
  #
  # @example Stopping an existing tunnel
  #   I2P::BOB::Tunnel.stop(:myssh)
  #
  # @see   http://www.i2p2.de/applications.html
  # @see   http://bob.i2p.to/bridge.html
  # @since 0.1.4
  class Tunnel
    ##
    # Starts up a new tunnel.
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [String, #to_s]  :nickname (Time.now.to_i)
    # @option options [KeyPair, #to_s] :keys     (nil)
    # @option options [Boolean]        :quiet    (false)
    # @option options [String, #to_s]  :inhost   ("localhost")
    # @option options [Integer, #to_i] :inport   (nil)
    # @option options [String, #to_s]  :outhost  ("localhost")
    # @option options [Integer, #to_i] :outport  (nil)
    # @return [Tunnel]
    def self.start(options = {}, &block)
      tunnel = self.new(options).start

      if block_given?
        begin
          result = block.call(tunnel)
        ensure
          tunnel.stop
        end
        result
      else
        tunnel
      end
    end

    ##
    # Shuts down an existing tunnel of the given `nickname`.
    #
    # @param  [String, #to_s]
    # @return [void]
    def self.stop(nickname)
      self.new(nickname).stop
    end

    ##
    # Initializes a new tunnel instance.
    #
    # @overload initialize(options = {})
    #   @param  [Hash{Symbol => Object}] options
    #   @option options [String, #to_s]  :nickname (Time.now.to_i)
    #   @option options [KeyPair, #to_s] :keys     (nil)
    #   @option options [Boolean]        :quiet    (false)
    #   @option options [String, #to_s]  :inhost   ("localhost")
    #   @option options [Integer, #to_i] :inport   (nil)
    #   @option options [String, #to_s]  :outhost  ("localhost")
    #   @option options [Integer, #to_i] :outport  (nil)
    #
    # @overload initialize(nickname)
    #   @param  [String, #to_s]          nickname
    #
    def initialize(options = {})
      case options
        when Hash
          # Create a new tunnel
          @nickname = options[:nickname] || Time.now.to_i.to_s
          @debug    = options[:debug]
          setup(options)
        else
          # Access an existing tunnel
          @nickname = options.to_s
          Client.open { |client| client.getnick(@nickname) }
      end
    end

    ##
    # Returns the nickname for this tunnel.
    #
    # @return [String]
    # @see    Client#getnick
    attr_reader :nickname

    ##
    # Returns the I2P {I2P::Destination destination} for this tunnel.
    #
    # @return [Destination]
    # @see    Client#getdest
    attr_reader :destination
    def destination
      @destination ||= client { getdest }
    end

    ##
    # Returns the I2P {I2P::KeyPair key pair} for this tunnel.
    #
    # @return [KeyPair]
    # @see    Client#getkeys
    attr_reader :keys
    def keys
      @keys ||= client { getkeys }
    end

    ##
    # Returns `true` if this is an inbound tunnel.
    #
    # @return [Boolean]
    def inbound?
      !!inport
    end

    ##
    # Returns the inbound host name or IP address for this tunnel.
    #
    # @return [String]
    # @see    Client#inhost
    attr_reader :inhost
    def inhost
      @inhost ||= begin
        nil # TODO
      end
    end

    ##
    # Returns the inbound port number for this tunnel.
    #
    # @return [Integer]
    # @see    Client#inport
    attr_reader :inport
    def inport
      @inport ||= begin
        nil # TODO
      end
    end

    ##
    # Returns `true` if this is an outbound tunnel.
    #
    # @return [Boolean]
    def outbound?
      !!outport
    end

    ##
    # Returns the outbound host name or IP address for this tunnel.
    #
    # @return [String]
    # @see    Client#outhost
    attr_reader :outhost
    def outhost
      @outhost ||= begin
        nil # TODO
      end
    end

    ##
    # Returns the outbound port number for this tunnel.
    #
    # @return [Integer]
    # @see    Client#outport
    attr_reader :outport
    def outport
      @outport ||= begin
        nil # TODO
      end
    end

    ##
    # Returns `true` if quiet mode is enabled for this tunnel.
    #
    # This only applies to outbound tunnels and has no effect on inbound
    # tunnels.
    #
    # @return [Boolean]
    # @see    Client#quiet
    def quiet?
      @quiet ||= begin
        nil # TODO
      end
    end

    ##
    # Registers the given tunnel `options` with the BOB bridge.
    #
    # @param  [Hash{Symbol => Object}] options
    # @return [void]
    def setup(options = {})
      client do |client|
        if options[:keys]
          client.setkeys(options[:keys])
        else
          begin
            client.getkeys
          rescue Error => e
            client.newkeys
          end
        end

        client.quiet(options[:quiet])      if options[:quiet]
        client.inhost(options[:inhost])    if options[:inhost]
        client.inport(options[:inport])    if options[:inport]
        client.outhost(options[:outhost])  if options[:outhost]
        client.outport(options[:outport])  if options[:outport]
      end
      self
    end
    alias_method :setup!, :setup

    ##
    # Returns `true` if this tunnel is currently active.
    #
    # @return [Boolean]
    def running?
      true # FIXME
    end
    alias_method :active?, :running?

    ##
    # Starts up this tunnel.
    #
    # @return [void]
    # @see    Client#start
    def start
      client { start }
      self
    end
    alias_method :start!, :start

    ##
    # Returns `true` if this tunnel is currently in the process of starting
    # up.
    #
    # @return [Boolean]
    def starting?
      # TODO
    end

    ##
    # Shuts down this tunnel.
    #
    # @return [void]
    # @see    Client#stop
    def stop
      client { stop }
      self
    end
    alias_method :stop!, :stop

    ##
    # Returns `true` if this tunnel is currently in the process of shutting
    # down.
    #
    # @return [Boolean]
    def stopping?
      # TODO
    end

    def socket
      client.socket
    end

    ##
    # Returns a {I2P::BOB::Client} instance for accessing low-level
    # information about this tunnel.
    #
    # @yield  [client]
    # @yieldparam [Client] client
    # @return [Client]
    def client(&block)
      Client.open(:nickname => nickname, :debug => @debug, &block)
    end
  end
end; end
