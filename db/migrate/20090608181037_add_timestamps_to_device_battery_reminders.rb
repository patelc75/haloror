class AddTimestampsToDeviceBatteryReminders < ActiveRecord::Migration
  def self.up
  	add_column :device_battery_reminders, :created_at, :timestamp
  	add_column :device_battery_reminders, :updated_at, :timestamp
  end

  def self.down
  	remove_column :device_battery_reminders, :created_at
  	remove_column :device_battery_reminders, :updated_at
  end
end
