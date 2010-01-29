require 'spec_helper'

describe Order do
  before(:each) do
    @valid_attributes = {
      :ship_name => "value for ship_name",
      :ship_address => "value for ship_address",
      :ship_city => "value for ship_city",
      :ship_state => "value for ship_state",
      :ship_zip => "value for ship_zip",
      :ship_phone => "value for ship_phone",
      :bill_name => "value for bill_name",
      :bill_address => "value for bill_address",
      :bill_city => "value for bill_city",
      :bill_state => "value for bill_state",
      :bill_zip => "value for bill_zip",
      :bill_phone => "value for bill_phone",
      :bill_email => "value for bill_email",
      :price => 1.5,
      :comments => "value for comments"
    }
  end

  it "should create a new instance given valid attributes" do
    Order.create!(@valid_attributes)
  end
end
