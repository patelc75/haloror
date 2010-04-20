class ReplaceGwOfflinePercWithOffset < ActiveRecord::Migration
  def self.up
    remove_column :system_timeouts,:gateway_offline_percentage
    add_column :system_timeouts,:gateway_offline_offset_sec,:integer
  end

  def self.down
    add_column :system_timeouts,:gateway_offline_percentage,:float
    remove_column :system_timeouts,:gateway_offline_offset_sec  	            
  end
end
