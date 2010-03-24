# steps for online direct to customer store
#
require "faker"

Given /^the product catalog exists$/ do
  {"Chest Strap" => "12001002-1", "Belt Clip" => "12001008-1"}.each do |type, part_number|
    DeviceType.find_or_create_by_device_type( type).device_models.find_or_create_by_part_number( part_number)
  end
end

Given /^the payment gateway response log is empty$/ do
  PaymentGatewayResponse.delete_all
end

When /^I fill the (.+) details for online store$/ do |which|
  %{When I choose "product_complete"}
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
      "email"       => Faker::Internet.email
    }.each do |field, value|
      When %{I fill in "order_#{which}_#{field}" with "#{value}"}
    end
    When %{I select "Alabama" from "order_#{which}_state"}

  elsif which == "credit card"
    { "card_number" => "4111111111111111",
      "card_csc"    => "111"}.each do |field, value|
      When %{I fill in "order_#{field}" with "#{value}"}
    end
    When %{I select "VISA" from "order_card_type"}
    When %{I select "January" from "order_card_expiry_2i"}
    When %{I select "#{2.years.from_now.to_date.year}" from "order_card_expiry_1i"}
  end
end

Then /^the payment gateway response should have (\d+) logs$/ do |row_count|
  assert_equal row_count.to_i, PaymentGatewayResponse.count
end

Then /^the payment gateway should have log for (\d+) USD$/ do |amount|
  assert_equal 1, PaymentGatewayResponse.count(:conditions => {:amount => (amount.to_i*100)})
end
