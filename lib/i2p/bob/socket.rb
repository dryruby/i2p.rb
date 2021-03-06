module I2P; module BOB
  ##
  # **I2P Basic Open Bridge (BOB) socket.**
  #
  # This class works just like Ruby's standard `TCPSocket` except that it
  # uses I2P name resolution and connectivity. It allows you to open a
  # socket to an I2P destination using either a Base64-encoded
  # {I2P::Destination destination address} or a friendly I2P name such as
  # `"forum.i2p"` or `"trac.i2p2.i2p"`.
  #
  # Under the covers, the class will create a BOB {I2P::BOB::Tunnel tunnel}
  # to the given destination from a random `localhost` port which it then
  # connects to in the usual `TCPSocket` manner. From thereon out, all
  # socket input and output is transported by BOB to and from the I2P
  # network. When the socket is closed, the BOB tunnel is removed as well.
  #
  # Note that establishing a new tunnel can take a while (typically, from 5
  # to 20 seconds).
  #
  # @example Opening a socket to an I2P destination using BOB
  #   I2P::BOB::Socket.open("bob.i2p") do |socket|
  #     socket.write "HEAD / HTTP/1.1\r\n\r\n"
  #     socket.flush
  #     until (line = socket.readline).chomp.empty?
  #       puts line
  #     end
  #     socket.close
  #   end
  #
  # @see   http://ruby-doc.org/core/classes/TCPSocket.html
  # @see   http://ruby-doc.org/core-1.9/classes/TCPSocket.html
  # @since 0.1.5
  class Socket < TCPSocket
    ##
    # Opens a socket connection to `destination`.
    #
    # @param  [Destination, #to_s]     destination
    # @param  [Hash{Symbol => Object}] options
    # @option options [String, #to_s]  :inhost ("127.0.0.1")
    # @option options [Integer, #to_i] :inport (rand)
    # @yield  [socket]
    # @yieldparam [Socket] socket
    # @return [Socket]
    def self.open(destination, options = {}, &block)
      socket = self.new(destination, options)

      if block_given?
        begin
          result = case block.arity
            when 1 then block.call(socket)
            else socket.instance_eval(&block)
          end
        ensure
          socket.close unless socket.closed?
        end
        result
      else
        socket
      end
    end

    ##
    # Initializes a new socket connection to `destination`.
    #
    # @param  [Destination, #to_s]     destination
    # @param  [Hash{Symbol => Object}] options
    # @option options [String, #to_s]  :inhost ("127.0.0.1")
    # @option options [Integer, #to_i] :inport (rand)
    def initialize(destination, options = {})
      @options     = options.dup
      @destination = destination

      begin
        ObjectSpace.define_finalizer(self, finalizer)

        @tunnel = Tunnel.new({
          :nickname => __id__.abs.to_s,
          :inhost   => (@options[:inhost] ||= '127.0.0.1'),
          :inport   => (@options[:inport] ||= random_port),
        })
        @tunnel.start

        super(@options[:inhost], @options[:inport])

        puts(@destination.__send__(respond_to?(:to_base64) ? :to_base64 : :to_s))
      rescue => error
        (@tunnel.remove rescue nil) if @tunnel
        ObjectSpace.undefine_finalizer(self)
        raise error
      end
    end

    ##
    # Returns the I2P {I2P::Destination destination} for this socket.
    #
    # @return [Destination]
    attr_reader :destination

    ##
    # Returns the underlying {Tunnel tunnel} for this socket.
    #
    # @return [Tunnel]
    attr_reader :tunnel

    ##
    # Closes the socket connection.
    #
    # @return [void]
    # @raise  [IOError] if the socket is already closed
    def close
      begin
        super
      ensure
        @tunnel.remove
      end
      return nil
    end

    ##
    # Closes the readable connection on this socket.
    #
    # @return [void]
    # @raise  [IOError] if the socket is already closed
    def close_read
      begin
        super
      ensure
        @tunnel.remove if closed?
      end
      return nil
    end

    ##
    # Closes the writable connection on this socket.
    #
    # @return [void]
    # @raise  [IOError] if the socket is already closed
    def close_write
      begin
        super
      ensure
        @tunnel.remove if closed?
      end
      return nil
    end

    ##
    # Shuts down the receive, sender, or both, parts of this socket.
    #
    # @param  [Integer] how
    # @return [Integer]
    def shutdown(how = 2)
      begin
        super
      ensure
        @tunnel.remove if closed?
      end
      return 0
    end

    # Get rid of some problematic IO methods:
    undef_method :reopen

  private

    ##
    # Returns a finalizer proc for this socket.
    #
    # The finalizer ensures that the underlying BOB tunnel is shut down and
    # removed when this object goes out of scope.
    #
    # @return [Proc]
    def finalizer
      lambda { |object_id| Tunnel.remove(object_id.abs.to_s) rescue nil }
    end

    ##
    # Returns an available TCP port number for `localhost`.
    #
    # @return [Integer]
    def random_port
      # NOTE: the BOB protocol unfortunately requires us to pick the port
      # that the BOB bridge will then proceed to bind; this introduces an
      # inherent and unavoidable race condition.
      TCPServer.open('127.0.0.1', 0) { |server| server.addr[1] }
    end
  end
end; end
