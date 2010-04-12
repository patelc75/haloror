class OrderHasCouponCode < ActiveRecord::Migration
  def self.up
    change_table :orders do |t|
      t.column :coupon_code, :string
    end
  end

  def self.down
    remove_column :orders, :coupon_code
  end
end
