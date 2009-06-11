class AddDeviceIdToDeviceBatteryReminders < ActiveRecord::Migration
  def self.up
  add_column :device_battery_reminders, :device_id, :integer
  end

  def self.down
  remove_column :device_battery_reminders, :device_id
  end
end
