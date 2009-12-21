class DropManyIndexes < ActiveRecord::Migration
  def self.up
    # steps
    remove_index :steps, [:user_id, :begin_timestamp], :quiet=>true	

    # skin_temps 
    remove_index :skin_temps, [:user_id, :timestamp], :quiet=>true

    # vitals
    remove_index :vitals, [:user_id, :timestamp], :quiet=>true

    # batteries 
    remove_index :batteries, [:user_id, :timestamp]

  end

  def self.down
    # steps
    add_index :steps, [:user_id, :begin_time]

    # skin_temps
    add_index :skin_temps, [:user_id, :timestamp]

    # vitals
    add_index :vitals, [:user_id, :timestamp]

    # batteries
    add_index :batteries [:user_id, :timestamp]
    
  end
end
