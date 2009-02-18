class RecreateInexesForSkinTemps < ActiveRecord::Migration
  def self.up
    remove_index :skin_temps, [:timestamp, :user_id]
    add_index :skin_temps, [:user_id, :timestamp]
  end

  def self.down
    remove_index :skin_temps, [:user_id, :timestamp]
    add_index :skin_temps, [:timestamp, :user_id]
  end
end
