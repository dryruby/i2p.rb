module I2P
  ##
  class Key < Structure
    ##
    # Reads a key data structure from the given `input` stream.
    #
    # @param  [IO, StringIO] input
    # @return [Key]
    def self.read(input)
      self.new(input.read(const_get(:BYTESIZE)))
    end

    ##
    # @return [String]
    attr_accessor :data

    ##
    # @param  [String] data
    def initialize(data)
      @data = data.to_s
    end

    ##
    # Returns `true` if this key is of the correct size.
    #
    # @return [Boolean]
    # @since  0.1.3
    def valid?
      @data.size.eql?(self.class.const_get(:BYTESIZE))
    end

    ##
    # Returns the binary string representation of this key.
    #
    # @return [String]
    def to_s
      @data
    end
  end
end
