class AddColumnsToFalls < ActiveRecord::Migration
  def self.up
    add_column :falls, :timestamp_call_center, :timestamp_with_time_zone
    add_column :falls, :call_center_pending, :boolean
    add_column :falls, :timestamp_server, :timestamp_with_time_zone    
  end

  def self.down
    drop_column :falls, :timestamp_call_center
    drop_column :falls, :call_center_pending
    drop_column :falls, :timestamp_server
  end
end
