class AddReconnectedAtToDeviceLatestQueries < ActiveRecord::Migration
  def self.up
    add_column :device_latest_queries, :reconnected_at, :datetime
  end

  def self.down
    drop_column :device_latest_queries, :reconnected_at
  end
end
