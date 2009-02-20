class AddDeviceIdZero < ActiveRecord::Migration
  def self.up
  	if(Device.find_by_id(0).nil?)
  	  execute "INSERT INTO devices (id, serial_number) VALUES ('0', '01234567890')"	
  	end
  end

  def self.down
  end
end
