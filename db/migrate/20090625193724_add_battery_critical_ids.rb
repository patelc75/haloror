class AddBatteryCriticalIds < ActiveRecord::Migration
  def self.up
  add_column :battery_reminders, :battery_critical_id, :integer
  add_column :device_battery_reminders, :battery_critical_id, :integer
  end

  def self.down
  remove_column :battery_reminders, :battery_critical_id
  remove_column :device_battery_reminders, :battery_critical_id
  end
end
