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
  end
end
