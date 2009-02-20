class AddDeviceIdZero < ActiveRecord::Migration
  def self.up
  	if(device=Device.find_by_id(0).nil?)
  	  if(device.serial_number != "0123456789")
  	    execute "UPDATE devices SET serial_number='0123456789' WHERE id=0"	
  	  else  	
  		execute "INSERT INTO devices (id, serial_number) VALUES ('0', '0123456789')"	
  	  end
  	end
  end

  def self.down
  end
end
