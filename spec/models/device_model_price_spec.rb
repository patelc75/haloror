require 'spec_helper'

describe DeviceModelPrice do
  before(:each) do
    @valid_attributes = {
      :device_model => 1,
      :coupon_code => "value for coupon_code",
      :expiry_date => Date.today,
      :deposit => 1,
      :shipping => 1,
      :monthly_recurring => 1,
      :months_advance => 1,
      :months_trial => 1
    }
  end

  it "should create a new instance given valid attributes" do
    DeviceModelPrice.create!(@valid_attributes)
  end
end
