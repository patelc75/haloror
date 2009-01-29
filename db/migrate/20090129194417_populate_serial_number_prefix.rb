class PopulateSerialNumberPrefix < ActiveRecord::Migration
  def self.up
    DeviceType.find(:all).each do |dt|
      if(dt.device_type == 'Chest Strap')
        dt.serial_number_prefix = 'H1'
        dt.save
      elsif(dt.device_type == 'Gateway')
        dt.serial_number_prefix = 'H2'
        dt.save
      end
    end
  end

  def self.down
  end
end
