class AddTimeRemainingToDeviceBatteryReminders < ActiveRecord::Migration
  def self.up
  add_column :device_battery_reminders, :time_remaining, :integer
  end

  def self.down
  remove_column :device_battery_reminders, :time_remaining
  end
end
