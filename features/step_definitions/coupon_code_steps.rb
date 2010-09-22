Given /^no coupon codes exist$/ do
  DeviceModelPrice.delete_all
end

Then /^coupon code "([^"]*)" should have a related (.+)$/ do |coupon, phrase|
  (coupon = DeviceModelPrice.find_by_coupon_code( coupon)).should_not be_blank
  relations = phrase.split(',').collect(&:strip)
  relations.each do |relation|
    case relation
    when 'device model'
      coupon.device_model.should_not be_blank
    when 'group'
      coupon.group.should_not be_blank
    end
  end
end
