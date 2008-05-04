class AddIndexesChartData < ActiveRecord::Migration
  def self.up
    add_index :batteries, [:timestamp, :user_id]
    add_index :vitals, [:timestamp, :user_id]
    # add_index :steps, [:timestamp, :user_id]
    add_index :skin_temps, [:timestamp, :user_id]
  end

  def self.down
    remove_index :batteries, [:timestamp, :user_id]
    remove_index :vitals, [:timestamp, :user_id]
    # remove_index :steps, [:timestamp, :user_id]
    remove_index :skin_temps, [:timestamp, :user_id]
  end
end
