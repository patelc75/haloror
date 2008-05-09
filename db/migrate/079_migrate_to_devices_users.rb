class MigrateToDevicesUsers < ActiveRecord::Migration
  def self.up
    drop_table :devices_user if
    ActiveRecord::Base.connection.tables.include?(:devices_user) 
  
    create_table :devices_users, :id => false, :force => true do |t|
      t.column :device_id, :integer
      t.column :user_id, :integer
    end
    
    Device.find(:all).each do |device|
      assoc = DevicesUsers.new
      assoc.user_id = device.user_id
      assoc.device_id = device.id
      assoc.save
    end
  end

  def self.down
    # not sure why this doesn't work, come back to it later
    #        if !(ActiveRecord::Base.connection.tables.include?(:devices_user))
    #      create_table :devices_user do |t|
    #        t.column :id, :primary_key, :null => false
    #        t.column :device_id, :integer
    #        t.column :user_id, :integer
    #      end
    #    end
    
    drop_table :devices_users if
    ActiveRecord::Base.connection.tables.include?(:devices_users) 
  end
end
