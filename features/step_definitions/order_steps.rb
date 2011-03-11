# ==========
# = givens =
# ==========

When /^the associated one time charge does not exist for the order$/ do
  pending # express the regexp above with the code you wish you had
end

When /^user :([^"]*)" approves the user intake form associated to last order$/ do |login|
  (user = User.find_by_login( login)).should_not be_blank
  Given %{I am authenticated as :#{user}" with password :12345"}
  When %{I am editing the user intake associated to last order}
  When %{I press :Approve"}
end

# =========
# = thens =
# =========

Then /^last order should have coupon code values copied$/ do
  (_order = Order.last).should_not be_blank
  (_coupon = _order.product_cost).should_not be_blank
  {
    :device_model_id      => :device_model_id,
    :cc_expiry_date       => :expiry_date,
    :cc_deposit           => :deposit,
    :cc_shipping          => :shipping,
    :cc_monthly_recurring => :monthly_recurring,
    :cc_months_advance    => :months_advance,
    :cc_months_trial      => :months_trial
  }.each { |k, v| _order.send( k).should == _coupon.send( v) }
end
