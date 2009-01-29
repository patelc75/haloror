class AddSerialNumberPrefixToDeviceType < ActiveRecord::Migration
  def self.up
    add_column :device_types, :serial_number_prefix, :string
  end

  def self.down
    remove_column :device_types, :serial_number_prefix
  end
end
