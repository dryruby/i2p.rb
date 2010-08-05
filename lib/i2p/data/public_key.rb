module I2P
  ##
  # **I2P public key data structure.**
  #
  # An I2P public key is a 2048-bit (256-byte) integer. The public key
  # represents only the exponent, not the primes, which are constant and
  # defined in the crypto spec.
  #
  # @see http://docs.i2p2.de/core/net/i2p/data/PublicKey.html
  class PublicKey < Key
    BYTESIZE = 256
  end
end
