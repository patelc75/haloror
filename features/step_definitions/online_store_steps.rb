# steps for online direct to customer store
#
require "faker"

Given /^the product catalog exists$/ do
  {
    "Chest Strap" => {
      :part_number => "12001002-1", :tariff => {
      :default => { :coupon_code => "",       :deposit => 249, :shipping => 15, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0},
      :expired => { :coupon_code => "EXPIRED", :deposit => 99, :shipping => 15, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0, :expiry_date => 1.month.ago.to_date},
      :declined => { :coupon_code => "DECLINED", :deposit => 3, :shipping => 0, :monthly_recurring => 59, :months_advance => 0, :months_trial => 0, :expiry_date => 1.month.ago.to_date},
      :trial =>   { :coupon_code => "99TRIAL", :deposit => 99, :shipping => 15, :monthly_recurring => 59, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now.to_date}
      }
    },
    "Belt Clip" => {
      :part_number => "12001008-1", :tariff => {
      :default => { :coupon_code => "",       :deposit => 249, :shipping => 15, :monthly_recurring => 49, :months_advance => 3, :months_trial => 0},
      :expired => { :coupon_code => "EXPIRED", :deposit => 99, :shipping => 15, :monthly_recurring => 49, :months_advance => 3, :months_trial => 0, :expiry_date => 1.month.ago.to_date},
      :declined => { :coupon_code => "DECLINED", :deposit => 3, :shipping => 0, :monthly_recurring => 49, :months_advance => 0, :months_trial => 0, :expiry_date => 1.month.ago.to_date},
      :trial =>   { :coupon_code => "99TRIAL", :deposit => 99, :shipping => 15, :monthly_recurring => 49, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now.to_date}
      }
    }
  }.each do |type, values|
    #
    # we assume the test database blank at all times. We therefore create the data for each scenario
    device_type = Factory.create(:device_type, :device_type => type)
    device_model = Factory.create(:device_model, :device_type => device_type, :part_number => values[:part_number])
    values[:tariff].each do |key, prices_hash|
      Factory.create(:device_model_price, prices_hash.merge(:device_model => device_model))
    end
  end
end

Given /^the payment gateway response log is empty$/ do
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
      "email"       => "cuc_senior@chirag.name"
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
  PaymentGatewayResponse.count(:conditions => {:amount => (amount.to_i*100)}).should == 1 unless amount.to_i.zero?
end

Then /^the payment gateway should not have log for (\d+) USD$/ do |amount|
  PaymentGatewayResponse.count(:conditions => {:amount => (amount.to_i*100)}).should == 0 unless amount.to_i.zero?
end
