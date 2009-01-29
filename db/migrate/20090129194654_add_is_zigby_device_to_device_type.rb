class AddIsZigbyDeviceToDeviceType < ActiveRecord::Migration
  def self.up
    add_column :device_types, :is_zigby_device, :boolean
  end

  def self.down
    remove_column :device_types, :is_zigby_device
  end
end
