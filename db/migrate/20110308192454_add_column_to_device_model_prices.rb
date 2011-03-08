class AddColumnToDeviceModelPrices < ActiveRecord::Migration
  def self.up
    add_column :device_model_prices, :dealer_install_fee, :integer
  end

  def self.down
    remove_column :device_model_prices, :dealer_install_fee
  end
end
