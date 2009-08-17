class AddTimestampServerToBatteryCriticals < ActiveRecord::Migration
  def self.up
  	add_column :battery_criticals, :timestamp_server, :timestamp_with_time_zone
  end

  def self.down
  	remove_column :battery_criticals, :timestamp_server
  end
end
