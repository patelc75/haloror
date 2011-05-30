class LocalizeCouponCodeInOrder < ActiveRecord::Migration
  def self.up
    Order.all( :conditions => ["coupon_code IS NULL OR coupon_code = ''"]).each do |_order|
      _order.update_attribute( :coupon_code, _order.product_cost.coupon_code)
    end
  end

  def self.down
    # nothing
  end
end
