class AddColumnsToGwAlarmButtons < ActiveRecord::Migration
  def self.up
    add_column :gw_alarm_buttons, :timestamp_call_center, :timestamp_with_time_zone
    add_column :gw_alarm_buttons, :call_center_pending, :boolean
    add_column :gw_alarm_buttons, :timestamp_server, :timestamp_with_time_zone    
  end

  def self.down
    drop_column :gw_alarm_buttons, :timestamp_call_center
    drop_column :gw_alarm_buttons, :call_center_pending
    drop_column :gw_alarm_buttons, :timestamp_server
  end
end
