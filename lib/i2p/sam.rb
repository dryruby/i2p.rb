module I2P
  ##
  # I2P Simple Anonymous Messaging (SAM) protocol.
  #
  # This is an implementation of the SAM V3 protocol, available since I2P
  # release 0.7.3.
  #
  # @see http://www.i2p2.de/applications.html
  # @see http://www.i2p2.de/samv3.html
  module SAM
    PROTOCOL_VERSION = 3.0
    DEFAULT_HOST     = (ENV['I2P_SAM_HOST'] || '127.0.0.1').to_s
    DEFAULT_PORT     = (ENV['I2P_SAM_PORT'] || 7656).to_i

    autoload :Client, 'i2p/sam/client'

    ##
    # I2P Simple Anonymous Messaging (SAM) protocol error conditions.
    class Error < StandardError                  # I2P_ERROR
      class ProtocolNotSupported < Error; end    # NOVERSION
      class SessionIDNotValid < Error; end       # INVALID_ID
      class SessionIDAlreadyUsed < Error; end    # DUPLICATED_ID
      class DestinationAlreadyUsed < Error; end  # DUPLICATED_DEST
      class KeyNotValid < Error; end             # INVALID_KEY
      class KeyNotFound < Error; end             # KEY_NOT_FOUND
      class PeerNotReachable < Error; end        # CANT_REACH_PEER
      class PeerNotFound < Error; end            # PEER_NOT_FOUND
      class Timeout < Error; end                 # TIMEOUT
    end
  end
end
