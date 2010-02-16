# steps for online direct to customer store
#

When /^I fill the (.+) details$/ do |which|
  which = which[0..3] # shipping, billing
  { "first_name"  => "#{which} first name",
    "last_name"   => "#{which} last name",
    "address"     => "#{which} ddress",
    "city"        => "#{which} city",
    "zip"         => "123456",
    "phone"       => "2120001112",
    "email"       => "#{which}@example.com"}.each do |field, value|
    When %{I fill in "#{which}_#{field}" with "#{value}"}
  end
  When %{I select "Alabama" from "#{which}_state"}
end


When /^I fill the credit card details$/ do
  { "card_number" => "4111111111111111",
    "card_csc"    => "123"}.each do |field, value|
    When %{I fill in "#{which}_#{field}" with "value"}
  end
  When %{I select "Visa" from "card_type"}
end
