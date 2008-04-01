class MigrateToDevicesUsers < ActiveRecord::Migration
  def self.up
    Device.find(:all).each do |device|
      assoc = DevicesUsers.new
      assoc.user_id = device.user_id
      assoc.device_id = device.id
      assoc.save
    end
  end

  def self.down
  end
end
