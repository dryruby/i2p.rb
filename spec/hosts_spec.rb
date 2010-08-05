require File.join(File.dirname(__FILE__), 'spec_helper')

describe I2P::Hosts do
  describe "I2P::Hosts[]" do
    it "returns a destination for known hostnames" do
      Hosts['forum.i2p'].should be_a(Destination)
    end

    it "returns nil for unknown hostnames" do
      Hosts['gjkeqrjgkfjgak.i2p'].should be_nil
    end
  end

  describe "I2P::Hosts.open without a block" do
    it "returns a new Hosts instance" do
      Hosts.open.should be_a(Hosts)
    end
  end

  describe "I2P::Hosts.open with a block" do
    # TODO
  end

  before :each do
    @hosts = I2P::Hosts.open
  end

  describe "I2P::Hosts#empty?" do
    it "returns true on an empty file" do
    end

    it "returns true on a non-empty file" do
    end
  end

  describe "I2P::Hosts#count" do
    it "returns the number of hostname lines" do
      # TODO
    end
  end

  describe "I2P::Hosts#include?" do
    it "returns true for matching hostnames" do
      @hosts.include?(/forum/).should be_true
    end

    it "returns false for non-matching hostnames" do
      @hosts.include?(/gjkeqrjgkfjgak/).should be_false
    end

    it "returns true for known hostnames" do
      @hosts.include?('forum.i2p').should be_true
    end

    it "returns false for unknown hostnames" do
      @hosts.include?('gjkeqrjgkfjgak.i2p').should be_false
    end

    it "returns true for known destinations" do
      @hosts.include?(@hosts['forum.i2p']).should be_true
    end

    it "returns false for unknown destinations" do
      # TODO
    end
  end

  describe "I2P::Hosts#[]" do
    it "returns a destination for known hostnames" do
      @hosts['forum.i2p'].should be_a(Destination)
    end

    it "returns nil for unknown hostnames" do
      @hosts['gjkeqrjgkfjgak.i2p'].should be_nil
    end
  end

  describe "I2P::Hosts#each with a block" do
    it "calls the block with two arguments" do
      @hosts.each { |*args| args.size.should == 2 }
    end

    it "calls the block once for each hostname mapping" do
      count = 0
      @hosts.each { |k, v| count += 1 }
      count.should == @hosts.count
    end

    it "returns an enumerator" do
      @hosts.each { |k, v| }.should be_an(defined?(Enumerator) ? Enumerator : Enumerable::Enumerator)
    end
  end

  describe "I2P::Hosts#each without a block" do
    it "returns an enumerator" do
      @hosts.each.should be_an(defined?(Enumerator) ? Enumerator : Enumerable::Enumerator)
    end
  end

  describe "I2P::Hosts#to_a" do
    it "returns an array" do
      @hosts.to_a.should be_an(Array)
    end

    it "returns an array with the correct number of elements" do
      @hosts.to_a.size.should == @hosts.count
    end
  end

  describe "I2P::Hosts#to_hash" do
    it "returns a hash" do
      @hosts.to_hash.should be_a(Hash)
    end

    it "returns a hash with the correct number of keys" do
      @hosts.to_hash.keys.size.should == @hosts.count
    end
  end

  describe "I2P::Hosts#to_s" do
    it "returns a string" do
      @hosts.to_s.should be_a(String)
    end

    it "returns a string with the correct number of lines" do
      @hosts.to_s.count("\n").should == @hosts.count
    end
  end
end
