require File.join(File.dirname(__FILE__), 'spec_helper')

describe I2P::BOB::Tunnel do
  describe "I2P::BOB::Tunnel.new" do
    it "returns a new BOB tunnel instance" do
      BOB::Tunnel.new.should be_a(BOB::Tunnel)
    end
  end

  # TODO
end
