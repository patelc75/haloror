# CHANGED: Given there are no coupon codes
#
# Given /^no coupon codes exist$/ do
#   DeviceModelPrice.delete_all
# end
Given /^"([^"]*)" coupon_code for "([^"]*)" group has (.+) shipping$/ do |_coupon_code, _group_name, _shipping|
  (_group = Group.find_by_name(_group_name)).should_not be_blank
  (_coupon = DeviceModelPrice.first( :conditions => { :coupon_code => _coupon_code, :group_id => _group.id} )).should_not be_blank
  _coupon.update_attribute( :shipping, _shipping.to_i).should be_true
end

# =========
# = thens =
# =========

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
