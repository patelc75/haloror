class AddDeviceLatestQueryUpdatedAtIndex < ActiveRecord::Migration
  def self.up
    add_index 'device_latest_queries', 'updated_at', :name => "device_latest_queries_updated_at_idx"
  end

  def self.down
    execute "drop index device_latest_queries_updated_at_idx"
  end
end
