require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'I2P::VERSION' do
  it "matches the VERSION file" do
    I2P::VERSION.to_s.should == File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).chomp
  end
end
