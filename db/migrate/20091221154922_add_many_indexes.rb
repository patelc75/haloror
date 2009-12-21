class AddManyIndexes < ActiveRecord::Migration
  def self.up
    # events
    add_index :events, [:user_id, :timestamp]

    # battery_pluggeds
    add_index :battery_pluggeds, [:device_id, :timestamp]

    # unbattery_pluggeds
    add_index :battery_unpluggeds, [:device_id, :timestamp]

    # mgmt_cmds 
    add_index :mgmt_cmds, [:device_id, :originator]
   
    # mgmt_queries
    add_index :mgmt_queries, [:device_id, :timestamp_server]
  
  end

  def self.down
    # events
    remove_index :events, [:user_id, :timestamp]

    # battery_pluggeds
    remove_index :battery_pluggeds, [:device_id, :timestamp]
   
    # battery_unpluggeds
    remove_index :battery_unpluggeds, [:device_id, :timestamp]

    # mgmt_cmds
    remove_index :mgmt_cmds, [:device_id, :originator]

    # mgmt_queries
    add_index :mgmt_queries, [:device_id, :timestamp_server]

  end
end
