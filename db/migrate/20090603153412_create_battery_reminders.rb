class CreateBatteryReminders < ActiveRecord::Migration
  def self.up
    create_table :battery_reminders do |t|
      t.column :id, :primary_key, :null => false
      t.integer :reminder_num
      t.integer :user_id
      t.integer :device_id
      t.timestamps
    end
  end

  def self.down
    drop_table :battery_reminders
  end
end
