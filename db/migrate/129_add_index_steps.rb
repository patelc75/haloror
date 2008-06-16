class AddIndexSteps < ActiveRecord::Migration
  def self.up
    add_index :steps, [:begin_timestamp, :user_id]
  end

  def self.down
    remove_index :steps, [:begin_timestamp, :user_id]
  end
end
