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

  context "A group will pick up default-group coupon codes if none exist for itself" do
    before( :each) do
      @group = Factory.create( :group) # create just another group. no coupon codes for this yet
      #
      # we remove all these because we might have created similar rows in outer scope of this scope
      [DeviceType, DeviceModel, DeviceModelPrice].each {|e| e.send( :delete_all)}
      # create one 'default' coupon code for CS and BC, each
      ['Chest Strap', 'Belt Clip'].each do |_type|
        _type = Factory.create( :device_type, :device_type => _type)
        _model = Factory.create( :device_model, :device_type => _type)
        [@group, Group.default!].each do |_group|
          Factory.create( :device_model_price, :coupon_code => 'default', :group => _group, :device_model => _model)
        end
      end
      @model = DeviceModel.first
      @my_coupon = DeviceModelPrice.first( :conditions => { :coupon_code => 'default', :device_model_id => @model, :group_id => @group })
      @default_clip_coupon = DeviceModelPrice.default( DeviceModel.myhalo_clip)
      @default_complete_coupon = DeviceModelPrice.default( DeviceModel.myhalo_complete)
    end
    
    specify { @group.coupon.should == DeviceModelPrice.default }
    specify { @group.coupon( :coupon_code => "anything").should == DeviceModelPrice.default }
    specify { @group.coupon( :coupon_code => "default").should == DeviceModelPrice.default }
    specify { @group.coupon( :device_model => DeviceModel.myhalo_clip).should == @default_clip_coupon }
    specify { @group.coupon( :device_model => DeviceModel.myhalo_complete).should == @default_complete_coupon }
    specify { @group.coupon( :coupon_code => 'default', :device_model => @model).should == @my_coupon }
  end
end