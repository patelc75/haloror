require 'spec_helper'

describe DeviceModelPrice do

  context "coupon with group" do
    before(:each) do
      @coupon = Factory.build( :device_model_price)
    end

    context "general and coupon code validity" do
      subject { @coupon }
      it { should be_valid }
      specify { @coupon.coupon_code.should_not be_blank }
      specify { @coupon.device_model.should_not be_blank}
    end

    # Every coupon code is associated to a group
    # No coupon codes are "orphan"
    context "group exists for each coupon code" do
      subject { @coupon.group }
      it { should_not be_blank }
      it { should be_valid }
    end
  end
  
  context "when group is missing" do
    before( :each) { @groupless_coupon = Factory.build( :device_model_price, :group => nil) }
    
    subject { @groupless_coupon }
    it { should_not be_valid }
    specify { @groupless_coupon.group.should be_blank }
  end
  
end
