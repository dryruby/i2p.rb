module I2P
  ##
  # **I2P certificate data structure.**
  #
  # Defines a certificate that can be attached to various I2P structures,
  # such as `RouterIdentity` and `Destination`, allowing routers and clients
  # to help manage denial of service attacks and the network utilization.
  #
  # @see   http://docs.i2p2.de/core/net/i2p/data/Certificate.html
  # @since 0.1.3
  class Certificate < Structure
    TYPE_NULL     = 0 # Null certificate
    TYPE_HASHCASH = 1 # Hashcash certificate
    TYPE_HIDDEN   = 2 # Hidden certificate
    TYPE_SIGNED   = 3 # Signed certificate
    TYPE_MULTIPLE = 4

    LENGTH_SIGNED_WITH_HASH = nil # TODO

    ##
    # Reads a certificate from the given `input` stream.
    #
    # @param  [IO, StringIO] input
    # @return [Certificate]
    def self.read(input)
      type    = input.read(1).unpack('c').first
      length  = input.read(2).unpack('n').first
      payload = length.zero? ? String.new : input.read(length)
      self.new(type, payload)
    end

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

    ##
    # Returns the binary string representation of this certificate.
    #
    # @return [String]
    def to_s
      StringIO.open do |buffer|
        buffer.write([type].pack('c'))
        if payload && !payload.empty?
          buffer.write([payload.size].pack('n'))
          buffer.write(payload.to_s)
        else
          buffer.write([0].pack('n'))
        end
        buffer.string
      end
    end
  end
end
