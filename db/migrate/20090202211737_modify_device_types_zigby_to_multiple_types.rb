class ModifyDeviceTypesZigbyToMultipleTypes < ActiveRecord::Migration
  def self.up
    remove_column :device_types, :is_zigby_device
      add_column :device_types, :mac_address_type, :integer
  end

  def self.down
    remove_column :device_types, :mac_address_type, :integer
    add_column :device_types, :is_zigby_device, :boolean
  end
end
