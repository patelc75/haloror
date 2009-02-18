class RecreateIndexesForSteps < ActiveRecord::Migration
  def self.up
    remove_index :steps, [:begin_timestamp, :user_id]
    add_index :steps, [:user_id, :begin_timestamp]
  end

  def self.down
    remove_index :steps, [:user_id, :begin_timestamp]
    add_index :steps, [:begin_timestamp, :user_id]
  end
end
