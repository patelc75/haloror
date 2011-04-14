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
    :cc_monthly_recurring => :monthly_recurring,
    :cc_months_advance    => :months_advance,
    :cc_months_trial      => :months_trial
  }.each { |k, v| _order.send( k).should == _coupon.send( v) }
  #   * shipping is special case
  if _coupon.shipping.blank?
    _order.cc_shipping.should == _order.shipping_option.price
  else
    _order.cc_shipping.should == _coupon.shipping
  end
end

Then /^shipping values get copied from (.+) for last order$/ do |_where, |
  (_order = Order.last).should_not be_blank
  case _where
  when 'shipping option'
    _order.ship_description.should == _order.shipping_option.description
    _order.ship_price.should       == _order.shipping_option.price
    
  when 'coupon code'
    (_product_cost = _order.product_cost).should_not be_blank
    _order.ship_description.should == "Coupon Code: #{_product_cost.coupon_code}"
    _order.ship_price.should       == _product_cost.shipping
  end
end

Then /^order items for each charge should be created separately for last order$/ do
  (_order = Order.last).should_not be_blank
  _order.order_items.recurring_charges.should_not be_blank
  (_cost = _order.product_cost).should_not be_blank
  [_cost.deposit, _cost.shipping, _cost.advance_charge, _cost.dealer_install_fee].reject(&:zero?).each do |_amount|
    _order.order_items.first( :conditions => { :cost => _amount }).should_not be_blank
  end
end

Then /^upfront charge for last order should include dealer install fee charges$/ do
  (_order = Order.last).should_not be_blank
  (_cost = _order.product_cost).should_not be_blank
  _recurring_sum = _order.order_items.recurring_charges.sum( :cost)
  _order.order_items.reject {|e| e.recurring_monthly != true }.sum( :conditions => { :cost => _cost.upfront_charge}).should_not be_blank
end
