# https://redmine.corp.halomonitor.com/issues/3562
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
    
    context "device_model exists for each coupon code" do
      subject { @coupon.device_model }
      it { should_not be_blank }
      it { should be_valid }
    end
  end
  
  context "when group is missing" do
    before( :each) { @invalid_coupon = Factory.build( :device_model_price, :group => nil) }
    
    specify { @invalid_coupon.should_not be_valid }
    specify { @invalid_coupon.group.should be_blank }
  end

  context "when device_model is missing" do
    before( :each) { @invalid_coupon = Factory.build( :device_model_price, :device_model => nil) }
    
    specify { @invalid_coupon.should_not be_valid }
    specify { @invalid_coupon.device_model.should be_blank }
  end
  
  context "one coupon code per device model per group" do
    before(:each) { @coupon = Factory.create( :device_model_price) }

    specify { Factory.build( :device_model_price, :coupon_code => @coupon.coupon_code, :group => @coupon.group ).should be_valid }
    specify { Factory.build( :device_model_price, :coupon_code => @coupon.coupon_code, :device_model => @coupon.device_model ).should be_valid }
    specify { Factory.create( :device_model_price).should be_valid }
    
    specify { Factory.build( :device_model_price, :coupon_code => @coupon.coupon_code, :group => @coupon.group, :device_model => @coupon.device_model ).should_not be_valid }
  end
end
