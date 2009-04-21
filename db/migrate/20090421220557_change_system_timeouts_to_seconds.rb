class ChangeSystemTimeoutsToSeconds < ActiveRecord::Migration
  def self.up
  	rename_column :system_timeouts, :gateway_offline_timeout_min, :gateway_offline_timeout_sec
  	rename_column :system_timeouts, :device_unavailable_timeout_min, :device_unavailable_timeout_sec
  	rename_column :system_timeouts, :strap_off_timeout_min, :strap_off_timeout_sec
  end

  def self.down
  	rename_column :system_timeouts, :gateway_offline_timeout_sec, :gateway_offline_timeout_min
  	rename_column :system_timeouts, :device_unavailable_timeout_sec, :device_unavailable_timeout_min
  	rename_column :system_timeouts, :strap_off_timeout_sec, :strap_off_timeout_min
  end
end
