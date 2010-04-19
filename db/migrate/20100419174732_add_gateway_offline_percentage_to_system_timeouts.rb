class AddGatewayOfflinePercentageToSystemTimeouts < ActiveRecord::Migration
  def self.up
  	add_column :system_timeouts,:gateway_offline_percentage,:float
  end

  def self.down
  	remove_column :system_timeouts,:gateway_offline_percentage
  end
end
