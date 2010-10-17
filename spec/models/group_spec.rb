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

  # DEPRECATED: Sun Oct 17 02:49:52 IST 2010
  #   every group now has its own coupon_codes
  #   default coupon codes are named "default" and belong to group named "default"
  #
  # # Instead of blank string, the default coupon code should use the string "default"
  # context "every group must have 'default' coupon_code" do
  #   subject { @group.default_coupon_code }
  #   it { should_not be_blank }
  #   it { should be_valid }
  #   
  #   context "name of the default coupon" do
  #     subject { @group.default_coupon_code.coupon_code }
  #     it { should_not be_blank }
  #     it { should == "default" }
  #   end
  # end
  context "A group will pick up default-group coupon codes if none exist for itself" do
    before( :each) do
      #
      # we remove all these because we might have created similar rows in outer scope of this scope
      [DeviceType, DeviceModel, DeviceModelPrice].each {|e| e.send( :delete_all)}
      # create one 'default' coupon code for CS and BC, each
      ['Chest Strap', 'Belt Clip'].each do |_type|
        _type = Factory.create( :device_type, :device_type => _type)
        _model = Factory.create( :device_model, :device_type => _type)
        Factory.create( :device_model_price, :coupon_code => 'default', :group => Group.default, :device_model => _model)
      end
      @group_no_cc = Factory.create( :group) # create just another group. no coupon codes for this yet
    end
    
    specify { @group_no_cc.default_coupon_code.should == Group.default.default_coupon_code( 'Chest Strap' ) }
    specify { @group_no_cc.default_coupon_code( 'Chest Strap').should == Group.default.default_coupon_code( 'Chest Strap' ) }
    specify { @group_no_cc.default_coupon_code( 'Belt Clip').should == Group.default.default_coupon_code( 'Belt Clip' ) }
  end
end