
# 
#  Mon Feb 28 23:17:24 IST 2011, ramonrails
#   * changed during the skype voice call
class AddCallCenterTimedOutToCriticalAlerts < ActiveRecord::Migration
  def self.up
    add_column :falls, :call_center_timed_out, :boolean
    add_column :panics, :call_center_timed_out, :boolean
    add_column :gw_alarm_buttons, :call_center_timed_out, :boolean
  end

  def self.down
    remove_column :falls, :call_center_timed_out
    remove_column :panics, :call_center_timed_out
    remove_column :gw_alarm_buttons, :call_center_timed_out
  end
end
