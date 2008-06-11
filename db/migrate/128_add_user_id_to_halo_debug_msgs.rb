class AddUserIdToHaloDebugMsgs < ActiveRecord::Migration
  def self.up
    add_column :halo_debug_msgs, :user_id, :integer
  end

  def self.down
    remove_column :halo_debug_msgs, :user_id
  end
end
