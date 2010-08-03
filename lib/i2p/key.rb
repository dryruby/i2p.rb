module I2P
  ##
  class Key
    ##
    # @param  [String] base64
    # @return [Key]
    def self.parse(base64)
      base64.gsub!('~', '/')
      base64.gsub!('-', '+')
      self.new(base64.unpack('m').first)
    end

    ##
    # @param  [String] data
    def initialize(data)
      @data = data.to_s
    end

    ##
    # @return [String]
    def to_s
      base64 = [@data].pack('m').delete("\n")
      base64.gsub!('/', '~')
      base64.gsub!('+', '-')
      base64
    end

    ##
    class Public < Key; end

    ##
    class Private < Key; end
  end
end
