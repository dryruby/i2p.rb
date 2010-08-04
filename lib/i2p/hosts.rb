module I2P
  ##
  # I2P address book parser.
  #
  # @example Opening the default hosts.txt file
  #   I2P::Hosts.open do |hosts|
  #     ...
  #   end
  #
  # @example Opening the given hosts.txt file
  #   I2P::Hosts.open("/path/to/hosts.txt") do |hosts|
  #     ...
  #   end
  #
  # @since 0.1.2
  class Hosts
    include Enumerable

    DEFAULT_FILE = '~/.i2p/hosts.txt' # Unix only

    ##
    # Looks up the I2P destination (public key) for `hostname`.
    #
    # @example
    #   I2P::Hosts["forum.i2p"]
    #
    # @param  [String, #to_s] hostname
    # @return [Key]
    def self.[](hostname)
      self.open { |hosts| hosts[hostname] }
    end

    ##
    # Opens a `hosts.txt` file for reading.
    #
    # @example Opening the default hosts.txt file
    #   I2P::Hosts.open do |hosts|
    #     ...
    #   end
    #
    # @example Opening the given hosts.txt file
    #   I2P::Hosts.open("/path/to/hosts.txt") do |hosts|
    #     ...
    #   end
    #
    # @param  [String, #to_s] filename
    # @param  [Hash{Symbol => Object}] options
    # @yield  [hosts]
    # @yieldparam [Hosts] hosts
    # @return [Hosts]
    def self.open(filename = DEFAULT_FILE, options = {}, &block)
      hosts = self.new(filename, options)
      block_given? ? block.call(hosts) : hosts
    end

    # @return [Hash]
    attr_reader :options

    # @return [Hash]
    attr_reader :cache

    # @return [String]
    attr_reader :filename

    ##
    # @param  [String, #to_s]          filename
    # @param  [Hash{Symbol => Object}] options
    # @yield  [hosts]
    # @yieldparam [Hosts] hosts
    def initialize(filename = DEFAULT_FILE, options = {}, &block)
      @cache    = {}
      @filename = File.expand_path(filename.to_s)
      @options  = options.dup
      block.call(self) if block_given?
    end

    ##
    # Returns `true` if `hosts.txt` doesn't contain any hostnames.
    #
    # @example
    #   hosts.empty?
    #
    # @return [Boolean]
    def empty?
      count.zero?
    end

    ##
    # Returns the number of hostnames in `hosts.txt`.
    #
    # @example
    #   hosts.count
    #
    # @return [Integer]
    def count
      each.count
    end

    ##
    # Returns `true` if `hosts.txt` includes `value`. The `value` can be
    # either a hostname or an I2P destination (public key).
    #
    # @example
    #   hosts.include?("forum.i2p")
    #
    # @param  [Key, Regexp, #to_s] value
    # @return [Boolean]
    def include?(value)
      case value
        when Key    then each.any? { |k, v| value.eql?(v) }
        when Regexp then each.any? { |k, v| value === k }
        else each.any? { |k, v| value.to_s.eql?(k) }
      end
    end

    ##
    # Returns the I2P destination (public key) for `hostname`.
    #
    # @example
    #   hosts["forum.i2p"]
    #
    # @param  [String, #to_s] hostname
    # @return [Key]
    def [](hostname)
      @cache[hostname.to_s] ||= each_line.find do |line|
        k, v = parse_line(line)
        break Key::Public.parse(v) if hostname === k
      end
    end

    ##
    # Enumerates the hostnames and I2P destinations in `hosts.txt`.
    #
    # @example
    #   hosts.each do |hostname, destination|
    #     ...
    #   end
    #
    # @yield  [hostname, destination]
    # @yieldparam [String] hostname
    # @yieldparam [Key]    destination
    # @return [Enumerator]
    def each(&block)
      if block_given?
        each_line do |line|
          k, v = parse_line(line)
          block.call(k, Key::Public.parse(v))
        end
      end
      enum_for(:each)
    end

    ##
    # Returns all hostname mappings as an array.
    #
    # @return [Array]
    def to_a
      each.inject([]) { |result, kv| result.push(kv) }
    end

    ##
    # Returns all hostname mappings as a hash.
    #
    # @return [Hash]
    def to_hash
      each.inject({}) { |result, (k, v)| result.merge!(k => v) }
    end

    ##
    # Returns all hostname mappings as a string.
    #
    # @return [String]
    def to_s
      each.inject([]) { |result, kv| result.push(kv.join('=')) }.push('').join($/)
    end

  protected

    ##
    # Enumerates each line in the `hosts.txt` file.
    #
    # @yield  [line]
    # @yieldparam [String] line
    # @return [Enumerator]
    def each_line(&block)
      if block_given?
        File.open(@filename, 'rb') do |file|
          file.each_line do |line|
            line, = line.split('#', 2) if line.include?(?#)
            line.chomp!.strip!
            block.call(line) unless line.empty?
          end
        end
      end
      enum_for(:each_line)
    end

    ##
    # Parses a hostname mapping line from `hosts.txt`.
    #
    # @param  [String]
    # @return [Array(String, String)]
    def parse_line(line)
      line.chomp.split('=', 2).map(&:strip)
    end
  end
end
