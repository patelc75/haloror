class AddStoppedAtToBatteryReminders < ActiveRecord::Migration
  def self.up
  add_column :battery_reminders, :stopped_at, :timestamp
  end

  def self.down
  remove_column :battery_reminders, :stopped_at
  end
end
