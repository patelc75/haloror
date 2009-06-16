class CreateDeviceBatteryReminders < ActiveRecord::Migration
  def self.up
    create_table :device_battery_reminders do |t|
      t.column :id,:integer, :null => false
      t.integer :reminder_num

      t.timestamp :stopped_at

    end
  end

  def self.down
    drop_table :device_battery_reminders
  end
end
