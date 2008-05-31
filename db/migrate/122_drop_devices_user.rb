class DropDevicesUser < ActiveRecord::Migration
  def self.up
    drop_table :devices_user if
      ActiveRecord::Base.connection.tables.include?(:devices_user)
  end

  def self.down
    create_table :devices_user do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :user_id, :integer
    end
  end
end
