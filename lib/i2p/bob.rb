module I2P
  ##
  # **I2P Basic Open Bridge (BOB) protocol.**
  #
  # This is an implementation of the BOB protocol, available since I2P
  # release [0.6.5](http://www.i2p2.de/release-0.6.5.html).
  #
  # Note that for security reasons, the BOB application bridge is not
  # enabled by default in new I2P installations. To use `I2P::BOB`,
  # you must first manually enable BOB in the router console's
  # [client configuration](http://localhost:7657/configclients.jsp).
  #
  # @see http://www.i2p2.de/applications.html
  # @see http://bob.i2p.to/bridge.html
  module BOB
    PROTOCOL_VERSION = 1
    DEFAULT_HOST     = (ENV['I2P_BOB_HOST'] || '127.0.0.1').to_s
    DEFAULT_PORT     = (ENV['I2P_BOB_PORT'] || 2827).to_i

    autoload :Client, 'i2p/bob/client'

    ##
    # **I2P Basic Open Bridge (BOB) protocol error conditions.**
    class Error < StandardError; end
  end
end
