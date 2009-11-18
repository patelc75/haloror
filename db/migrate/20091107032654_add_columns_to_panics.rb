class AddColumnsToPanics < ActiveRecord::Migration
  def self.up
    add_column :panics, :timestamp_call_center, :timestamp_with_time_zone
    add_column :panics, :call_center_pending, :boolean
    add_column :panics, :timestamp_server, :timestamp_with_time_zone    
  end

  def self.down
    drop_column :panics, :timestamp_call_center
    drop_column :panics, :call_center_pending
    drop_column :panics, :timestamp_server
  end
end
