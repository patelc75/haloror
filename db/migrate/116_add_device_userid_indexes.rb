class AddDeviceUseridIndexes < ActiveRecord::Migration
  def self.up 
    add_index :battery_criticals, :device_id
    add_index :battery_charge_completes, :device_id
    add_index :access_logs, :user_id
    add_index :profiles, :user_id
    add_index :roles_users, :user_id
    add_index :roles_users, :role_id
end

def self.down
    remove_index :battery_criticals, :device_id
    remove_index :battery_charge_completes, :device_id    
    remove_index :access_logs, :user_id
    remove_index :profiles, :user_id
    remove_index :roles_users, :user_id
    remove_index :roles_users, :role_id
  end
end
