require "spec_helper"

describe DeviceModel do
  before(:all) { product_catalog }

  context "validity" do
    before(:each) { @device_model = Factory.create( :device_model) }
    subject { @device_model }

    it { should_not be_blank }
    it { should be_valid }
  end
  
  context "can find complete or clip by the phrase" do
    ["complete", "clip"].each do |what|
      specify { DeviceModel.find_complete_or_clip( what).should_not be_blank }
    end
  end

  context "should pick default tarriff / coupon code with complete/clip phrase" do
    group = Group.find_by_name("bestbuy")
    ["complete", "clip"].each do |what|
      specify { DeviceModel.find_complete_or_clip( what).tariff.should be_blank }
      debugger
      specify { DeviceModel.find_complete_or_clip( what).tariff( :group => group).should_not be_blank }
      specify { DeviceModel.find_complete_or_clip( what).tariff( :group => group).coupon_code.should == "default" }
    end
  end
  
  # after(:all) do
  #   [DeviceType, DeviceModel, DeviceModelPrice].each {|e| e.delete_all }
  # end
end

def product_catalog
  {
    "Chest Strap" => {
      :part_number => "12001002-1", :tariff => {
      :default => { :coupon_code => "default", :deposit => 249, :shipping => 15, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0},
      :expired => { :coupon_code => "EXPIRED", :deposit => 99, :shipping => 15, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0, :expiry_date => 1.month.ago.to_date},
      :declined => { :coupon_code => "DECLINED", :deposit => 3, :shipping => 0, :monthly_recurring => 59, :months_advance => 0, :months_trial => 0, :expiry_date => 1.month.ago.to_date},
      :trial =>   { :coupon_code => "99TRIAL", :deposit => 99, :shipping => 15, :monthly_recurring => 59, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now.to_date},
      :custom =>   { :coupon_code => "group_name_here", :deposit => 99, :shipping => 15, :monthly_recurring => 59, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now.to_date}
      }
    },
    "Belt Clip" => {
      :part_number => "12001008-1", :tariff => {
      :default => { :coupon_code => "default", :deposit => 249, :shipping => 15, :monthly_recurring => 49, :months_advance => 3, :months_trial => 0},
      :expired => { :coupon_code => "EXPIRED", :deposit => 99, :shipping => 15, :monthly_recurring => 49, :months_advance => 3, :months_trial => 0, :expiry_date => 1.month.ago.to_date},
      :declined => { :coupon_code => "DECLINED", :deposit => 3, :shipping => 0, :monthly_recurring => 49, :months_advance => 0, :months_trial => 0, :expiry_date => 1.month.ago.to_date},
      :trial =>   { :coupon_code => "99TRIAL", :deposit => 99, :shipping => 15, :monthly_recurring => 49, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now.to_date},
      :custom =>   { :coupon_code => "group_name_here", :deposit => 99, :shipping => 15, :monthly_recurring => 49, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now.to_date}
      }
    }
  }.each do |type, values|
    #
    # we assume the test database blank at all times. We therefore create the data for each scenario
    @device_type = DeviceType.find_by_device_type( type)
    @device_type = Factory.create(:device_type, :device_type => type) if @device_type.blank?
    @device_type.should_not be_blank
    @device_model = DeviceModel.first( :conditions => { :device_type_id => @device_type.id, :part_number => values[:part_number]})
    @device_model = Factory.create(:device_model, :device_type => @device_type, :part_number => values[:part_number]) if @device_model.blank?
    @device_model.should_not be_blank
    ["direct_to_consumer", "bestbuy"].each do |group_name|
      debugger
      (group = (Group.find_by_name( group_name) || Factory.create( :group, :name => group_name))).should_not be_blank
      values[:tariff].each do |key, prices_hash|
        prices_hash[:coupon_code] = group_name.upcase if key == :custom
        (Factory.create(:device_model_price, prices_hash.merge(:device_model => @device_model, :group => group))).should_not be_blank
      end
    end
  end
end