require File.join(File.dirname(__FILE__), 'spec_helper')

describe I2P::SAM::Client do
  include I2P::SAM

  describe "I2P::SAM::Client.open" do
    it "returns a new SAM client instance" do
      SAM::Client.open.should be_a(SAM::Client)
    end
  end

  describe "I2P::SAM::Client.new" do
    it "returns a new SAM client instance" do
      SAM::Client.new.should be_a(SAM::Client)
    end
  end

  before :each do
    @client = SAM::Client.new
  end

  describe "I2P::SAM::Client#connected?" do
    it "returns true when connected" do
      @client.connect
      @client.should be_connected
    end

    it "returns false when disconnected" do
      @client.disconnect
      @client.should_not be_connected
    end
  end

  describe "I2P::SAM::Client#connect" do
    it "connects to the SAM bridge" do
      @client.should_not be_connected
      @client.connect
      @client.should be_connected
    end

    it "returns self" do
      @client.connect.should equal(@client)
    end
  end

  describe "I2P::SAM::Client#disconnect" do
    before(:each) { @client.hello }

    it "disconnects from the SAM bridge" do
      @client.should be_connected
      @client.disconnect
      @client.should_not be_connected
    end

    it "returns self" do
      @client.connect.should equal(@client)
    end
  end

  describe "I2P::SAM::Client#hello without a version" do
    it "raises no errors" do
      lambda { @client.hello }.should_not raise_error
    end

    it "returns a float" do
      @client.hello.should be_a(Float)
    end

    it "returns the protocol version" do
      @client.hello.should == SAM::PROTOCOL_VERSION
    end
  end

  describe "I2P::SAM::Client#hello with a valid version" do
    it "raises no errors" do
      lambda { @client.hello(:min => 1, :max => 3) }.should_not raise_error
    end

    it "returns a float" do
      @client.hello.should be_a(Float)
    end

    it "returns the protocol version" do
      @client.hello(:min => 1, :max => 3).should == SAM::PROTOCOL_VERSION
    end
  end

  describe "I2P::SAM::Client#hello with an invalid version" do
    it "raises a ProtocolNotSupported error" do
      lambda { @client.hello(:min => 9, :max => 9) }.should raise_error(SAM::Error::ProtocolNotSupported)
    end
  end

  describe "I2P::SAM::Client#lookup_name for existing names" do
    before(:each) { @client.hello }

    it "returns a public key" do
      @client.lookup_name('forum.i2p').should be_a(Key::Public)
    end

    it "returns the correct public key" do
      @client.lookup_name('forum.i2p').to_s.should == "XaZscxXGaXxuIkZDX87dfN0dcEG1xwSXktDbMX9YBOQ1LWbf0j6Kzde37j8dlPUhUK9kqVRZWpDtP7a2QBRl3aT~t~bYRj5bgTOIf9hTW46iViKdKObR-wPPjej~Px8OSYrXbFv2KUekS4baXcqHS7aJMy4rcbC1hsJm3qcXtut~7VFwEhg9w-HrHhsT5aYtcr4u79HvNvUva38NQ4NJn7vI9OPhPVgb5gxkefgM1tF0QC6QO1b~RADN~BW~X2S-YRPyKKxv6xx9mfqEbl5lVA1nBTaoFsN5ZfLZoJOFIVNpNoXxCrCQhvG2zjS-pJD2NF6g0bCcT4cKBWPYtJenLiK3L6fKJuVJ-og5ootLdJNBXGsO~FSwdabvDUaPDbTKmqS-ibFjmq1C7vEde3TGo3cRZgqG0YZi3S3BpBTYN9kGhYHrThGH69ECViUJnUWlUsWux5FI4pZL5Du7TwDYT0BwnX2kTdZQ8WGSFlflXgVQIh1n0XpElShWrOQPR0jGAAAA"
    end
  end

  describe "I2P::SAM::Client#lookup_name for nonexistent names" do
    before(:each) { @client.hello }

    it "raises a KeyNotFound error" do
      lambda { @client.lookup_name('foobar.i2p') }.should raise_error(SAM::Error::KeyNotFound)
    end
  end

  describe "I2P::SAM::Client#lookup_name for invalid names" do
    before(:each) { @client.hello }

    it "raises a KeyNotFound error" do
      lambda { @client.lookup_name('123') }.should raise_error(SAM::Error::KeyNotFound)
    end
  end

  describe "I2P::SAM::Client#generate_dest" do
    before(:each) { @client.hello }

    it "returns a two-element array" do
      @client.generate_dest.should be_an(Array)
      @client.generate_dest.size.should == 2
    end

    it "generates a new asymmetric key pair" do
      private_key, public_key = @client.generate_dest
      private_key.should be_a(Key::Private)
      public_key.should be_a(Key::Public)
    end
  end
end
