class AddUserIdToOscopeMsg < ActiveRecord::Migration
  def self.up
    add_column :oscope_msgs, :user_id, :integer
  end

  def self.down
    remove_column :oscope_msgs, :user_id
  end
end
