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
    # @param  [Object] other
    # @return [Boolean]
    def eql?(other)
      other.is_a?(Key) && self == other
    end

    ##
    # @param  [Object] other
    # @return [Boolean]
    def ==(other)
      to_s == other.to_s
    end

    ##
    # @return [String]
    def to_s
      base64 = [@data].pack('m').delete("\n")
      base64.gsub!('/', '~')
      base64.gsub!('+', '-')
      base64
    end
  end
end
