# steps for online direct to customer store
#
require "faker"

Given /^the product catalog exists$/ do
  #
  # remove any existing data for product catalog
  # Given %{there are no device types, device models, device model prices}
  [DeviceType, DeviceModel, DeviceModelPrice].each(&:delete_all)
  #
  # Now create what we need
  {
    "Chest Strap" => {
      :part_number => "12001002-1", :tariff => {
      :default  => { :coupon_code => "default",         :deposit => 249,  :shipping => 15, :dealer_install_fee => 50, :monthly_recurring => 59, :months_advance => 0, :months_trial => 0},
      :expired  => { :coupon_code => "EXPIRED",         :deposit => 99,   :shipping => 15, :dealer_install_fee => 50, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0, :expiry_date => 1.month.from_now.to_date},
      :declined => { :coupon_code => "DECLINED",        :deposit => 3,    :shipping => 0,  :dealer_install_fee => 50, :monthly_recurring => 59, :months_advance => 0, :months_trial => 0, :expiry_date => 1.month.from_now.to_date},
      :trial    => { :coupon_code => "99TRIAL",         :deposit => 99,   :shipping => 15, :dealer_install_fee => 50, :monthly_recurring => 59, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now.to_date},
      :snapback => { :coupon_code => "SNAPBACK",        :deposit => 55,   :shipping => 55, :dealer_install_fee => 50, :monthly_recurring => 5,  :months_advance => 0, :months_trial => 0, :expiry_date => 1.month.from_now.to_date},
      :custom   => { :coupon_code => "group_name_here", :deposit => 99,   :shipping => 15, :dealer_install_fee => 50, :monthly_recurring => 59, :months_advance => 0, :months_trial => 0, :expiry_date => 1.month.from_now.to_date}
      }
    },
    "Belt Clip" => {
      :part_number => "12001008-1", :tariff => {
      :default  => { :coupon_code => "default",         :deposit => 249,  :shipping => 15, :dealer_install_fee => 50, :monthly_recurring => 49, :months_advance => 0, :months_trial => 0},
      :expired  => { :coupon_code => "EXPIRED",         :deposit => 99,   :shipping => 15, :dealer_install_fee => 50, :monthly_recurring => 49, :months_advance => 3, :months_trial => 0, :expiry_date => 1.month.from_now.to_date},
      :declined => { :coupon_code => "DECLINED",        :deposit => 3,    :shipping => 0,  :dealer_install_fee => 50, :monthly_recurring => 49, :months_advance => 0, :months_trial => 0, :expiry_date => 1.month.from_now.to_date},
      :trial    => { :coupon_code => "99TRIAL",         :deposit => 99,   :shipping => 15, :dealer_install_fee => 50, :monthly_recurring => 49, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now.to_date},
      :snapback => { :coupon_code => "SNAPBACK",        :deposit => 55,   :shipping => 55, :dealer_install_fee => 50, :monthly_recurring => 5,  :months_advance => 0, :months_trial => 0, :expiry_date => 1.month.from_now.to_date},
      :custom   => { :coupon_code => "group_name_here", :deposit => 99,   :shipping => 15, :dealer_install_fee => 50, :monthly_recurring => 49, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now.to_date}
      }
    }
  }.each do |type, values|
    #
    # we assume the test database blank at all times. We therefore create the data for each scenario
    if ( device_type = DeviceType.find_by_device_type( type) ).blank?
      device_type = Factory.create(:device_type, :device_type => type)
    end
    if ( device_model = DeviceModel.first( :conditions => {:device_type_id => device_type.id, :part_number => values[:part_number]}) ).blank?
      device_model = Factory.create(:device_model, :device_type => device_type, :part_number => values[:part_number])
    end
    # Sun Oct 17 03:55:29 IST 2010
    #   * 'default' Group now has 'default' coupon_code
    #   * when any coupon code is invalid for a group, it will return 'default' coupon_code of 'default' group
    default_group = Group.default!
    ["direct_to_consumer", "bestbuy", 'default'].each do |group_name|
      group = (Group.find_by_name( group_name) || Factory.create( :group, :name => group_name))
      # 
      #  Thu Jan 13 00:32:00 IST 2011, ramonrails
      #   * For 'default' group create all keys
      #   * For any other group, do not create 'SNAPBACK' key
      _hash = ((group_name == 'default') ? values[:tariff] : (values[:tariff].reject { |k,v| k == :snapback }))
      _hash.each do |key, prices_hash|
        prices_hash[:coupon_code] = group_name.upcase if key == :custom
        if DeviceModelPrice.first( :conditions => { :device_model_id => device_model.id, :coupon_code => prices_hash[:coupon_code], :group_id => group.id}).blank?
          Factory.create(:device_model_price, prices_hash.merge(:device_model => device_model, :group => group))
        end
      end
    end
  end
end

# =========
# = whens =
# =========

When /^I place an online order for "([^\"]*)" group$/ do |_name|
  When %{I am placing an online order for "#{_name}" group}
  When %{I fill in "Coupon Code" with "#{_name}_coupon"}
  When %{I press "Continue"}
  When %{I press "Place Order"}
end

When /^I am placing an online order for "([^\"]*)" group$/ do |_name|
  When %{I switch "#{_name}" group for online store}
  When %{I choose "product_complete"}
  When %{I choose "S_22_28_inches"}
  When %{I fill the shipping details for online store}
  When %{I fill the billing details for online store}
  When %{I fill the credit card details for online store}
  When %{I uncheck "order_bill_address_same"}
end

When /^I create a coupon code for "([^\"]*)" group$/ do |_name|
  _names = _name.split(',').collect(&:strip).each do |_group_name|
    When %{I am ready to create a coupon code for "#{_group_name}" group}
    When %{I press "Save"}
  end
end

When /^I am ready to create a coupon code for "([^\"]*)" group$/ do |_name|
  When %{I go to the home page}
  When %{I follow links "Config > Coupon Codes > New coupon code"}
  When "I select the following:", table(%{
    | Group                             | #{_name}                  |
    | Product                           | 12001002-1 -- Chest Strap |
    | device_model_price_expiry_date_1i | 2012                      |
  })
  When "I fill in the following:", table(%{
    | Coupon code              | #{_name}_coupon |
    | Deposit                  | 77              |
    | Shipping                 | 7               |
    | Monthly recurring        | 45              |
    | months to pay in advance | 0               |
    | free trial months        | 0               |
    | Dealer Install Fee       | 99              |
  })
end

When /^I switch "([^\"]*)" group for online store$/ do |_name|
  When %{I visit "/orders/switch_group"}
  if response.body.include? "Please select a group"
    When %{I select "#{_name}" from "Group"}
    When %{I press "Continue"}
  end
end

When /^I am switching the group for online store$/ do
  When %{I visit "/orders/switch_group"}
end

When /^I erase the payment gateway response log$/ do
  PaymentGatewayResponse.delete_all
end

When /^I fill the (.+) details for online store$/ do |which|
  if ['shipping', 'billing'].include?(which)
    which = which[0..3] # shipping, billing
    #
    # use Faker gem to generate random data. Avoid "Duplicate transaction" errors from gateway
    { "first_name"  => Faker::Name.first_name,
      "last_name"   => Faker::Name.last_name,
      "address"     => Faker::Address.street_address,
      "city"        => Faker::Address.city,
      "zip"         => Faker::Address.zip_code,
      "phone"       => Faker::PhoneNumber.phone_number,
      "email"       => "cuc_#{which}@chirag.name"
    }.each do |field, value|
      When %{I fill in "order_#{which}_#{field}" with "#{value}"}
    end
    When %{I select "Alabama" from "order_#{which}_state"}

  elsif which == "credit card"
    { "card_number" => "4111111111111111",
      "cvv"    => "111"}.each do |field, value|
      When %{I fill in "order_#{field}" with "#{value}"}
    end
    When %{I select "VISA" from "order_card_type"}
    When %{I select "January" from "order_card_expiry_2i"}
    When %{I select "#{2.years.from_now.to_date.year}" from "order_card_expiry_1i"}
  end
end

When /^I fill the test user for online store$/ do
  When %{I fill in "order_ship_first_name" with "first name"}
  When %{I fill in "order_ship_last_name" with "last name"}
  When %{I fill in "order_ship_address" with "address"}
  When %{I fill in "order_ship_city" with "city"}
  When %{I fill in "order_ship_zip" with "11111"}
  When %{I select "Alabama" from "order_ship_state"}
  When %{I fill in "order_ship_phone" with "1234567890"}
  When %{I fill in "order_ship_email" with "test@user.me"}
end

# =========
# = thens =
# =========

Then /^subscription start date should be (\d+) and (\d+) months away for "([^\"]*)"$/ do |advance, free, bill_first_name|
  order = Order.find_by_ship_first_name(bill_first_name)
  order.should_not be_blank
  
  recurring = order.payment_gateway_responses.find_by_action("recurring")
  recurring.should_not be_blank
  
  Date.parse(recursively_search_hash(Hash.from_xml(recurring.request_data), "startDate").first).should == (advance.to_i + free.to_i).months.from_now.to_date
end

Then /^billing and shipping addresses should not be same$/ do
  order = Order.last # just pick the last data
  ship = []; bill = []
  ["first_name", "last_name", "address", "city", "state", "zip", "phone", "email"].each do |field|
    ship << eval("order.ship_#{field}")
    bill << eval("order.bill_#{field}")
  end
  ship.join.should_not == bill.join # just one field different will mean different address
end

Then /^the payment gateway response should have (\d+) logs?$/ do |row_count|
  assert_equal row_count.to_i, PaymentGatewayResponse.count
end

Then /^the payment gateway should have log for (\d+) USD$/ do |amount|
  PaymentGatewayResponse.count(:conditions => {:amount => (amount.to_i*100)}).should == 1
end

Then /^the payment gateway should not have log for (\d+) USD$/ do |amount|
  PaymentGatewayResponse.count(:conditions => {:amount => (amount.to_i*100)}).should == 0
end

Then /^last order should be associated to "([^\"]*)" group$/ do |group_name|
  if defined?(Spec::Rails::Matchers)
    Order.last.group_name.should == group_name
  else
    assert_equal group_name, Order.last.group_name
  end
end

Then /^last order should have associated user intake$/ do
  if defined?(Spec::Rails::Matchers)
    Order.last.user_intake.should_not be_nil
  else
    assert_not_equal nil, Order.last.user_intake
  end
end

Then /^last order should not have associated user intake$/ do
  if defined?(Spec::Rails::Matchers)
    Order.last.user_intake.should be_nil
  else
    assert_equal nil, Order.last.user_intake
  end
end

Then /^caregivers of last order (should|should not) be activated$/ do |_state|
  (order = Order.last).should_not be_blank
  order.user_intake.should_not be_blank
  order.user_intake.caregivers.each do |e|
    if _state == 'should'
      e.should be_activated
    else
      e.should_not be_activated
    end
  end
end

Then /^product size for last (order|user intake) should be "([^"]*)"$/ do |_model, _size|
  (_row = _model.gsub(/ /,'_').classify.constantize.last).should_not be_blank
  _row.device_model_size.should == _size
end
