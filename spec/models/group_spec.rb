require File.join(File.dirname(__FILE__), "..", "spec_helper")
# require File.join(File.dirname(__FILE__), "..", "..", "test", "factories", "factories")

describe Group do
  specify { Group.new.should_not be_valid }
  
  before(:each) { @group = Factory.create(:group) }
  after(:each) { @group.destroy }
  
  context 'creating group' do
    subject { @group }
    it { should be_valid }
  end
  
  context 'triage threshold values' do
    subject { @group.triage_thresholds }
    it { should_not be_blank }
  end

  specify { @group.new_record?.should be_false }
  specify { @group.triage_thresholds.first.should be_valid }
  
  # A group exists for DTC public customers (direct_to_consumer)
  context "direct_to_consumer group exists or gets created" do
    before(:each) { @dtc = Group.direct_to_consumer }
    
    subject { @dtc }
    it { should_not be_blank }
    it { should be_valid }
    specify { @dtc.name.should == "direct_to_consumer" }
  end
  
  # Instead of blank string, the default coupon code should use the string "default"
  context "every group must have 'default' coupon_code" do
    subject { @group.default_coupon_code }
    it { should_not be_blank }
    it { should be_valid }
    
    context "name of the default coupon" do
      subject { @group.default_coupon_code.coupon_code }
      it { should_not be_blank }
      it { should == "default" }
    end
  end
end