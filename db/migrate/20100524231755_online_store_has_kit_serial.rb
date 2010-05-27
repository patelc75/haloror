class OnlineStoreHasKitSerial < ActiveRecord::Migration
  def self.up
    add_column :orders, :kit_serial, :string
  end

  def self.down
    remove_column :orders, :kit_serial
  end
end
