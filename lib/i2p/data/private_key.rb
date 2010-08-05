module I2P
  ##
  # **I2P private key data structure.**
  #
  # An I2P private key is a 2048-bit (256-byte) integer. The private key
  # represents only the exponent, not the primes, which are constant and
  # defined in the crypto spec.
  #
  # @see http://docs.i2p2.de/core/net/i2p/data/PrivateKey.html
  class PrivateKey < Key
    BYTESIZE = 256
  end
end
