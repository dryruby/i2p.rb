module I2P
  ##
  class Key < Structure
    ##
    # @param  [String] base64
    # @return [Key]
    def self.parse(base64)
      base64.gsub!('~', '/')
      base64.gsub!('-', '+')
      self.new(base64.unpack('m').first)
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
