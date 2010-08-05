require 'java'
require 'i2p'
require 'i2p.jar'

module I2P
  ##
  # @since 0.1.3
  module SDK
    import 'net.i2p'
    import 'net.i2p.client'
    import 'net.i2p.client.datagram'
    import 'net.i2p.client.naming'
    import 'net.i2p.crypto'
    import 'net.i2p.data'
    import 'net.i2p.data.i2cp'
    import 'net.i2p.stat'
    import 'net.i2p.time'
    import 'net.i2p.util'
  end
end

class I2P::Certificate
  ##
  # Returns an instance of the Java class `net.i2p.data.Certificate`.
  #
  # This method only works with JRuby, not with MRI or YARV.
  #
  # @return [Object]
  def to_java
    I2P::SDK::Certificate.new(type.to_i, payload.to_s.to_java_bytes)
  end
end

class I2P::PrivateKey
  ##
  # Returns an instance of the Java class `net.i2p.data.PrivateKey`.
  #
  # This method only works with JRuby, not with MRI or YARV.
  #
  # @return [Object]
  def to_java
    # TODO
  end
end

class I2P::SigningPrivateKey
  ##
  # Returns an instance of the Java class `net.i2p.data.SigningPrivateKey`.
  #
  # This method only works with JRuby, not with MRI or YARV.
  #
  # @return [Object]
  def to_java
    # TODO
  end
end

class I2P::PublicKey
  ##
  # Returns an instance of the Java class `net.i2p.data.PublicKey`.
  #
  # This method only works with JRuby, not with MRI or YARV.
  #
  # @return [Object]
  def to_java
    # TODO
  end
end

class I2P::SigningPublicKey
  ##
  # Returns an instance of the Java class `net.i2p.data.SigningPublicKey`.
  #
  # This method only works with JRuby, not with MRI or YARV.
  #
  # @return [Object]
  def to_java
    # TODO
  end
end

class I2P::Destination
  ##
  # Returns an instance of the Java class `net.i2p.data.Destination`.
  #
  # This method only works with JRuby, not with MRI or YARV.
  #
  # @return [Object]
  def to_java
    # TODO
  end
end

class I2P::KeyPair
  ##
  # Returns an instance of the Java class `net.i2p.data.PrivateKeyFile`.
  #
  # This method only works with JRuby, not with MRI or YARV.
  #
  # @return [Object]
  def to_java
    # TODO
  end
end
