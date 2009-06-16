class AddUserIdToDeviceBatteryReminders < ActiveRecord::Migration
  def self.up
  add_column :device_battery_reminders, :user_id, :integer
  end

  def self.down
  remove_column :device_battery_reminders, :user_id
  end
end
