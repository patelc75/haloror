class CouponCodesHaveGroup < ActiveRecord::Migration
  def self.up
    add_column :device_model_prices, :group_id, :integer
  end

  def self.down
    add_column :device_model_prices, :group_id
  end
end
