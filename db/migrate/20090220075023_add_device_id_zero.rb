class AddDeviceIdZero < ActiveRecord::Migration
  def self.up
  	device=Device.find_by_id(0)
  	if(device.nil?)
  	  execute "INSERT INTO devices (id, serial_number) VALUES ('0', '0123456789')"	
  	elsif(device.serial_number != "0123456789")
  	  execute "UPDATE devices SET serial_number='0123456789' WHERE id=0"	
  	end
  end

  def self.down
  end
end
