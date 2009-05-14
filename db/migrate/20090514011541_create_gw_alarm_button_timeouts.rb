class CreateGwAlarmButtonTimeouts < ActiveRecord::Migration
  def self.up
  	create_table :gw_alarm_button_timeouts, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :user_id, :integer
      t.column :event_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :pending, :boolean
    end
  end

  def self.down
    drop_table :gw_alarm_button_timeouts
  end
end
