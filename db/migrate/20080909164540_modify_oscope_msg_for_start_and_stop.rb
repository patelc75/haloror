class ModifyOscopeMsgForStartAndStop < ActiveRecord::Migration
  def self.up
    add_column :oscope_msgs, :oscope_start_msg_id, :integer
    add_column :oscope_msgs, :oscope_stop_msg_id, :integer
  end

  def self.down
    remove_column :oscope_msgs, :oscope_start_msg_id
    remove_column :oscope_msgs, :oscope_stop_msg_id
  end
end
