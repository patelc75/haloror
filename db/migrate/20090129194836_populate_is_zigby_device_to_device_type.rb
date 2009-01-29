class PopulateIsZigbyDeviceToDeviceType < ActiveRecord::Migration
  def self.up
    DeviceType.find(:all).each do |dt|
      if(dt.serial_number_prefix == 'H1' || dt.serial_number_prefix == 'H3')
        dt.is_zigby_device = true
      else
        dt.is_zigby_device = false
      end  
      dt.save
    end    
  end

  def self.down
  end
end
