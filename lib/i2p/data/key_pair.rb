module I2P
  ##
  # **I2P key pair data structure.**
  #
  # @see   http://docs.i2p2.de/core/net/i2p/data/PrivateKeyFile.html
  # @since 0.1.3
  class KeyPair < Structure
    BYTESIZE = 663 # minimum

    ##
    # Reads a key pair from the given `input` stream.
    #
    # @param  [IO, StringIO] input
    # @return [KeyPair]
    def self.read(input)
      self.new(Destination.read(input), PrivateKey.read(input), SigningPrivateKey.read(input))
    end

    ##
    # Initializes a new key pair instance.
    #
    # @param  [Destination]       destination
    # @param  [PrivateKey]        private_key
    # @param  [SigningPrivateKey] signing_key
    def initialize(destination, private_key, signing_key)
      @destination = destination
      @private_key = private_key
      @signing_key = signing_key
    end

    ##
    # @return [Destination]
    attr_accessor :destination

    ##
    # @return [PrivateKey]
    attr_accessor :private_key

    ##
    # @return [SigningPrivateKey]
    attr_accessor :signing_key

    ##
    # Returns the byte size of this key pair.
    #
    # @return [Integer]
    def size
      destination.size + private_key.size + signing_key.size
    end
    alias_method :bytesize, :size

    ##
    # Returns the binary string representation of this key pair.
    #
    # @return [String]
    def to_s
      StringIO.open do |buffer|
        buffer.write(destination.to_s)
        buffer.write(private_key.to_s)
        buffer.write(signing_key.to_s)
        buffer.string
      end
    end
  end
end
