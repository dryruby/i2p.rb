module I2P
  ##
  # **I2P data structure.**
  #
  # Defines a base class for I2P data structures.
  #
  # @see http://docs.i2p2.de/core/net/i2p/data/DataStructure.html
  # @see http://docs.i2p2.de/core/net/i2p/data/DataStructureImpl.html
  class Structure
    ##
    # Parses a data structure from the given `base64` string.
    #
    # @param  [String, #to_s] base64
    # @return [Structure]
    def self.parse(base64)
      base64 = base64.dup
      base64.gsub!('~', '/')
      base64.gsub!('-', '+')
      self.read(StringIO.new(base64.unpack('m').first))
    end

    ##
    # Reads a data structure from the given `input` stream.
    #
    # @param  [IO, StringIO] input
    # @return [Structure]
    def self.read(input)
      raise NotImplementedError.new("#{self}.read")
    end

    ##
    # Returns the byte size of this data structure.
    #
    # @return [Integer]
    def size
      if self.class.const_defined?(:BYTESIZE)
        self.class.const_get(:BYTESIZE)
      else
        raise NotImplementedError.new("#{self.class}#size")
      end
    end
    alias_method :bytesize, :size

    ##
    # Returns the Base64-encoded representation of this data structure.
    #
    # @return [String]
    def to_base64
      base64 = [to_s].pack('m').delete("\n")
      base64.gsub!('/', '~')
      base64.gsub!('+', '-')
      base64
    end

    ##
    # Returns the binary string representation of this data structure.
    #
    # @return [String]
    def to_s
      raise NotImplementedError.new("#{self.class}#to_s")
    end
  end
end
