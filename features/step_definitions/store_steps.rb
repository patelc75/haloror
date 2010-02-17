# steps for online direct to customer store
#

When /^I fill the (.+) details$/ do |which|
  if ['shipping', 'billing'].include?(which)
    which = which[0..3] # shipping, billing
    { "first_name"  => "#{which} first name",
      "last_name"   => "#{which} last name",
      "address"     => "#{which} address",
      "city"        => "#{which} city",
      "zip"         => "22001",
      "phone"       => "2120001112",
      "email"       => "#{which}@example.com"}.each do |field, value|
      When %{I fill in "order_#{which}_#{field}" with "#{value}"}
    end
    When %{I select "Alabama" from "order_#{which}_state"}

  elsif which == "credit card"
    { "card_number" => "4111111111111111",
      "card_csc"    => "111"}.each do |field, value|
      When %{I fill in "order_#{field}" with "#{value}"}
    end
    When %{I select "Visa" from "order_card_type"}
    When %{I select "January" from "order_card_expiry_2i"}
    When %{I select "#{1.year.from_now.to_date.year}" from "order_card_expiry_1i"}
  end
end
