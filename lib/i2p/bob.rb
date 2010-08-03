module I2P
  ##
  # I2P Basic Open Bridge (BOB) protocol.
  #
  # @see http://www.i2p2.de/applications.html
  # @see http://bob.i2p.to/bridge.html
  module BOB
    PROTOCOL_VERSION = 1
    DEFAULT_HOST     = (ENV['I2P_BOB_HOST'] || '127.0.0.1').to_s
    DEFAULT_PORT     = (ENV['I2P_BOB_PORT'] || 2827).to_i

    autoload :Client, 'i2p/bob/client'
  end
end
