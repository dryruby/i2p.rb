module I2P
  ##
  # **I2P destination data structure.**
  #
  # Defines an endpoint in the I2P network. The destination may move around
  # in the network, but messages sent to the destination will reach it.
  #
  # @see   http://docs.i2p2.de/core/net/i2p/data/Destination.html
  # @since 0.1.3
  class Destination < Structure
    BYTESIZE = 387 # minimum

    ##
    # Reads a destination from the given `input` stream.
    #
    # @param  [IO, StringIO] input
    # @return [Destination]
    def self.read(input)
      self.new(PublicKey.read(input), SigningPublicKey.read(input), Certificate.read(input))
    end

    ##
    # Initializes a new destination instance.
    #
    # @param  [PublicKey]        public_key
    # @param  [SigningPublicKey] signing_key
    # @param  [Certificate]      certificate
    def initialize(public_key, signing_key, certificate = Certificate.new)
      @public_key  = public_key
      @signing_key = signing_key
      @certificate = certificate
    end

    ##
    # @return [PublicKey]
    attr_accessor :public_key

    ##
    # @return [SigningPublicKey]
    attr_accessor :signing_key

    ##
    # @return [Certificate]
    attr_accessor :certificate

    ##
    # Returns the byte size of this data structure.
    #
    # @return [Integer]
    def size
      public_key.size + signing_key.size + certificate.size
    end
    alias_method :bytesize, :size

    ##
    # Returns the binary string representation of this destination.
    #
    # @return [String]
    def to_s
      StringIO.open do |buffer|
        buffer.write(public_key.to_s)
        buffer.write(signing_key.to_s)
        buffer.write(certificate.to_s)
        buffer.string
      end
    end
  end
end
