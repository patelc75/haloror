class AddDeviceModelSizeToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :device_model_size, :string
  end

  def self.down
    remove_column :orders, :device_model_size
  end
end
