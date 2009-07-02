class AddTimeRemainingToBatteryReminders < ActiveRecord::Migration
  def self.up
    add_column :battery_reminders, :time_remaining, :integer
  end

  def self.down
	remove_column :battery_reminders, :time_remaining
  end
end
