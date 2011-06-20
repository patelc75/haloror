require File.join( RAILS_ROOT, 'spec', 'spec_helper')

describe DeviceType do
  
  context "valid" do
    before( :each) { @device_type = Factory.create(:device_type) }
    subject { @device_type }
    it { should_not be_blank }
    it { should be_valid }
  end
  
  context "invalid" do
    before(:each) { @device_type = DeviceType.new }
    subject { @device_type }
    # it { should_not be_valid } # no validations for now
    specify { @device_type.device_type.should be_blank }
  end
end
