require File.join(File.dirname(__FILE__), 'spec_helper')

describe I2P::BOB do
  describe "I2P::BOB::Client.open" do
    it "returns a new BOB client instance" do
      BOB::Client.open.should be_a(BOB::Client)
    end
  end

  describe "I2P::BOB::Client.new" do
    it "returns a new BOB client instance" do
      BOB::Client.new.should be_a(BOB::Client)
    end
  end

  before :each do
    @client = BOB::Client.new
  end

  describe "I2P::BOB::Client#connected?" do
    it "returns true when connected" do
      @client.connect
      @client.should be_connected
    end

    it "returns false when disconnected" do
      @client.disconnect
      @client.should_not be_connected
    end
  end

  describe "I2P::BOB::Client#connect" do
    it "connects to the BOB bridge" do
      @client.should_not be_connected
      @client.connect
      @client.should be_connected
    end

    it "returns self" do
      @client.connect.should equal(@client)
    end
  end

  describe "I2P::BOB::Client#disconnect" do
    before(:each) { @client.connect }

    it "disconnects from the BOB bridge" do
      @client.should be_connected
      @client.disconnect
      @client.should_not be_connected
    end

    it "returns self" do
      @client.connect.should equal(@client)
    end
  end

  describe "I2P::BOB::Client#quit" do
    it "raises no errors" do
      lambda { @client.quit }.should_not raise_error
    end

    it "disconnects from the BOB bridge" do
      @client.connect
      @client.should be_connected
      @client.quit
      @client.should_not be_connected
    end

    it "returns self" do
      @client.connect.should equal(@client)
    end
  end

  describe "I2P::BOB::Client#verify" do
    it "returns true for valid keys" do
      @client.verify(I2P::Hosts['forum.i2p']).should be_true
    end

    it "returns false for invalid keys" do
      @client.verify('foobar').should be_false
    end
  end
end
