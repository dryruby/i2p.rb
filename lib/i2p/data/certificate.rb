module I2P
  ##
  # **I2P certificate data structure.**
  #
  # Defines a certificate that can be attached to various I2P structures,
  # such as `RouterIdentity` and `Destination`, allowing routers and clients
  # to help manage denial of service attacks and the network utilization.
  #
  # @see http://docs.i2p2.de/core/net/i2p/data/Certificate.html
  class Certificate < Structure
    TYPE_NULL     = 0 # Null certificate
    TYPE_HASHCASH = 1 # Hashcash certificate
    TYPE_HIDDEN   = 2 # Hidden certificate
    TYPE_SIGNED   = 3 # Signed certificate
    TYPE_MULTIPLE = 4

    LENGTH_SIGNED_WITH_HASH = nil # TODO

    ##
    # @return [Integer]
    attr_accessor :type

    ##
    # @return [String]
    attr_accessor :payload

    ##
    # Initializes a new certificate instance.
    #
    # @param  [Integer, #to_i] type
    # @param  [String, #to_s]  payload
    def initialize(type = TYPE_NULL, payload = String.new)
      @type, @payload = type.to_i, payload
    end

    ##
    # Returns the byte size of this certificate.
    #
    # @return [Integer]
    def size
      1 + 2 + (payload ? payload.size : 0)
    end
    alias_method :bytesize, :size
  end
end
