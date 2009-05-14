class AddEventTypeToGwAlarmTimeouts < ActiveRecord::Migration
  def self.up
  	add_column :gw_alarm_button_timeouts, :event_type, :string
  end

  def self.down
  	remove_column :gw_alarm_button_timeouts, :event_type
  end
end