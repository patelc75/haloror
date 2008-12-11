class AddIndexesOscopesMsgs < ActiveRecord::Migration
  def self.up
    add_index :points, :oscope_msg_id
    add_index :oscope_msgs, :oscope_start_msg_id
  end

  def self.down
    remove_index :points, :oscope_msg_id
    remove_index :oscope_msgs, :oscope_start_msg_id
  end
end
