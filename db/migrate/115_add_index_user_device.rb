class AddIndexUserDevice < ActiveRecord::Migration
  def self.up
    add_index :devices_users, :device_id
    add_index :devices_users, :user_id
  end

  def self.down
    remove_index :devices_users, :device_id
    remove_index :devices_users, :user_id
  end
end
