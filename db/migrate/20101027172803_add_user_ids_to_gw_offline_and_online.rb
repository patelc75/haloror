class AddUserIdsToGwOfflineAndOnline < ActiveRecord::Migration
  def self.up
    add_column :gateway_offline_alerts, :user_id, :integer
    add_column :gateway_online_alerts, :user_id, :integer
  end

  def self.down
	  remove_column :gateway_offline_alerts, :user_id
	  remove_column :gateway_online_alerts, :user_id
  end
end

