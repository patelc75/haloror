class AddBatteryRemindersToSystemTimeouts < ActiveRecord::Migration
  def self.up
  	add_column :system_timeouts,:battery_reminder_two_sec,:integer
  	add_column :system_timeouts,:battery_reminder_three_sec,:integer
  end

  def self.down
  	remove_column :system_timeouts,:battery_reminder_two_sec
  	remove_column :system_timeouts,:battery_reminder_three_sec
  end
end
