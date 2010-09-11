class AddColumnsToBatteryReminders < ActiveRecord::Migration
  def self.up
    add_column :battery_reminders, :timestamp_call_center, :timestamp_with_time_zone
    add_column :battery_reminders, :call_center_pending, :boolean
    add_column :battery_reminders, :timestamp_server, :timestamp_with_time_zone    
  end

  def self.down
    drop_column :battery_reminders, :timestamp_call_center
    drop_column :battery_reminders, :call_center_pending
    drop_column :battery_reminders, :timestamp_server
  end
end
