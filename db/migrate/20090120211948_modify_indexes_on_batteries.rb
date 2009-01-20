class ModifyIndexesOnBatteries < ActiveRecord::Migration
  def self.up
    remove_index :batteries, [:timestamp, :device_id]
    add_index    :batteries, [:device_id, :timestamp]
    remove_index :batteries, [:timestamp, :user_id]
    add_index    :batteries, [:user_id, :timestamp]
  end

  def self.down
    remove_index :batteries, [:device_id, :timestamp]
    add_index    :batteries, [:timestamp, :device_id]
    remove_index :batteries, [:user_id, :timestamp]
    add_index    :batteries, [:timestamp, :user_id]  
  end
end
