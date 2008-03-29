class AddDeviceIdToBatteries < ActiveRecord::Migration
  def self.up
    add_column :batteries, :device_id, :integer
  end

  def self.down
    remove_column :batteries, :device_id
  end
end
