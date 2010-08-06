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
    it "requires an argument" do
      lambda { @client.verify }.should raise_error(ArgumentError)
    end

    it "returns true for valid key pairs" do
      @client.verify(I2P::SAM::Client.open { |sam| sam.generate_dest }).should be_true
    end

    it "returns true for valid destinations" do
      @client.verify(I2P::Hosts['forum.i2p']).should be_true
    end

    it "returns false for valid public keys" do
      @client.verify(I2P::Hosts['forum.i2p'].public_key).should be_false
    end

    it "returns false for invalid inputs" do
      @client.verify('foobar').should be_false
    end
  end

  describe "I2P::BOB::Client#setnick" do
    after(:each)  { @client.clear rescue nil }

    it "requires an argument" do
      lambda { @client.setnick }.should raise_error(ArgumentError)
    end

    it "returns self" do
      @client.setnick(:spec).should equal(@client)
    end
  end

  describe "I2P::BOB::Client#getnick" do
    before(:each) { @client.setnick(:spec) }
    after(:each)  { @client.clear }

    it "returns self" do
      @client.getnick(:spec).should equal(@client)
    end
  end

  describe "I2P::BOB::Client#newkeys" do
    before(:each) { @client.setnick(:spec) }
    after(:each)  { @client.clear }

    it "returns a destination" do
      @client.newkeys.should be_a(Destination)
    end
  end

  describe "I2P::BOB::Client#getdest" do
    before(:each) { @client.setnick(:spec).newkeys }
    after(:each)  { @client.clear }

    it "returns a destination" do
      @client.getdest.should be_a(Destination)
    end
  end

  describe "I2P::BOB::Client#getkeys" do
    before(:each) { @client.setnick(:spec).newkeys }
    after(:each)  { @client.clear }

    it "returns a key pair" do
      @client.getkeys.should be_a(KeyPair)
    end
  end

  describe "I2P::BOB::Client#setkeys" do
    before(:each) { @client.setnick(:spec).newkeys }
    after(:each)  { @client.clear }

    it "requires an argument" do
      lambda { @client.setkeys }.should raise_error(ArgumentError)
    end

    it "returns self" do
      @client.setkeys(@client.getkeys).should equal(@client)
    end
  end

  describe "I2P::BOB::Client#inhost" do
    before(:each) { @client.setnick(:spec).newkeys }
    after(:each)  { @client.clear }

    it "requires an argument" do
      lambda { @client.inhost }.should raise_error(ArgumentError)
    end

    it "returns self" do
      @client.inhost('127.0.0.1').should equal(@client)
    end
  end

  describe "I2P::BOB::Client#inport" do
    before(:each) { @client.setnick(:spec).newkeys }
    after(:each)  { @client.clear }

    it "requires an argument" do
      lambda { @client.inport }.should raise_error(ArgumentError)
    end

    it "returns self" do
      @client.inport(37337).should equal(@client)
    end
  end

  describe "I2P::BOB::Client#clear" do
    before(:each) { @client.setnick(:spec) }

    it "returns self" do
      @client.clear.should equal(@client)
    end
  end
end
