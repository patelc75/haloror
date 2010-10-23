class AddUserIdsToGwAndDeviceAlerts < ActiveRecord::Migration
  def self.up
    add_column :device_available_alerts, :user_id, :integer
    add_column :device_unavailable_alerts, :user_id, :integer
    add_column :strap_off_alerts, :user_id, :integer
    add_column :strap_on_alerts, :user_id, :integer
  end

  def self.down
	  remove_column :device_available_alerts, :user_id
	  remove_column :device_unavailable_alerts, :user_id
	  remove_column :strap_off_alerts, :user_id
	  remove_column :strap_on_alerts, :user_id	  	  
  end
end
