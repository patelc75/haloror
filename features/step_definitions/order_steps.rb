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

When /^I switch senior of last order to become "([^"]*)" of "([^"]*)"$/ do |_role, _group_name|
  ( _order = Order.last).should_not be_blank
  ( _ui    = _order.user_intake).should_not be_blank
  ( _user  = _ui.senior).should_not be_blank
  ( _group = Group.find_by_name( _group_name)).should_not be_blank
  #   clear out this existing role for all objects
  _user.send( "is_#{_role}_of_what".to_sym).each do |_object|
    _user.has_no_role _role, _object
  end
  _user.has_no_role _role # if any without object
  #   add a new role for this group
  _user.add_role( _role, _group)
  _user.send( "is_#{_role}_of?".to_sym, _group).should be_true
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
  [_cost.deposit, _cost.shipping, _cost.advance_charge].reject(&:zero?).each do |_amount|
    _order.order_items.first( :conditions => { :cost => _amount }).should_not be_blank
  end 
  if _order.dealer_install_fee_applies == true                         
    _order.order_items.first( :conditions => { :cost => _cost.dealer_install_fee }).should_not be_blank                                                              
  end
end

Then /^upfront charge for last order should include dealer install fee charges$/ do
  (_order = Order.last).should_not be_blank
  (_cost = _order.product_cost).should_not be_blank
  _recurring_sum = _order.order_items.recurring_charges.sum( :cost)
  _order.order_items.reject {|e| e.recurring_monthly != true }.sum( :conditions => { :cost => _cost.upfront_charge( _order)}).should_not be_blank
end

Then /^last order group should be "([^"]*)"$/ do |_group_name|
  (_order = Order.last).should_not be_blank
  _order.group.should_not be_blank
  _order.group.name.should == _group_name
end

