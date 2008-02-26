class CreateDevicesUsers < ActiveRecord::Migration
  def self.up
    create_table :devices_users do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :devices_users
  end
end
