class AddDeviceTypeToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :device_type, :string
  end

  def self.down
    remove_column :devices, :device_type
  end
end
