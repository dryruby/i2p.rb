module I2P; module BOB
  ##
  # I2P Basic Open Bridge (BOB) client.
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
  end
end; end
