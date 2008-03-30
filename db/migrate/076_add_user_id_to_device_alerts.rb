class AddUserIdToDeviceAlerts < ActiveRecord::Migration
  def self.up
    add_column :strap_removeds, :user_id, :integer
    add_column :battery_criticals, :user_id, :integer
    add_column :battery_charge_completes, :user_id, :integer
    add_column :battery_unpluggeds, :user_id, :integer
    add_column :battery_pluggeds, :user_id, :integer
    add_column :strap_fasteneds, :user_id, :integer
  end
  
  def self.down
    remove_column :strap_removeds, :user_id
    remove_column :battery_criticals, :user_id
    remove_column :battery_charge_completes, :user_id
    remove_column :battery_unpluggeds, :user_id
    remove_column :battery_pluggeds, :user_id
    remove_column :strap_fasteneds, :user_id
  end
end