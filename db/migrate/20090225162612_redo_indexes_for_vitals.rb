class RedoIndexesForVitals < ActiveRecord::Migration
  def self.up
    remove_index :vitals, [:timestamp, :user_id]
    add_index :vitals, [:user_id, :timestamp]
    
    remove_index :vitals, [:timestamp, :user_id, :heartrate]
    add_index :vitals, [:user_id, :timestamp, :heartrate]
    
    remove_index :steps, [:begin_timestamp, :user_id, :steps]
    add_index :steps, [:user_id, :begin_timestamp, :steps]
    
    remove_index :batteries, [:timestamp, :user_id, :percentage]
    add_index :batteries, [:user_id, :timestamp, :percentage]
    
    remove_index :skin_temps, [:timestamp, :user_id, :skin_temp]
    add_index :skin_temps, [:user_id, :timestamp, :skin_temp]
  end

  def self.down
    remove_index :vitals, [:user_id, :timestamp]
    add_index :vitals, [:timestamp, :user_id]
    
    remove_index :vitals, [:user_id, :timestamp, :heartrate]
    add_index :vitals, [:timestamp, :user_id, :heartrate]
    
    remove_index :steps, [:user_id, :begin_timestamp, :steps]
    add_index :steps, [:begin_timestamp, :user_id, :steps]
    
    remove_index :batteries, [:user_id, :timestamp, :percentage]
    add_index :batteries, [:timestamp, :user_id, :percentage]
    
    remove_index :skin_temps, [:user_id, :timestamp, :skin_temp]
    add_index :skin_temps, [:timestamp, :user_id, :skin_temp]
  end
end
