class AddTimestampServerToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :timestamp_server, :timestamp_with_time_zone
  end

  def self.down
    remove_column :events, :timestamp_server
  end
end
