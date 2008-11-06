class PopulateDeviceTypesDevices < ActiveRecord::Migration
  def self.up
    cs = DeviceType.create(:type => 'Chest Strap',  :model => 'strap gen2',         :part_number => '22001001-1C')
    gw = DeviceType.create(:type => 'Gateway',      :model => 'halo gateway gen2',  :part_number => '22001005-1B')
    Device.find(:all, :conditions => "device_type = 'Halo Chest Strap'").each do |device|
      device.device_type_id = cs.id
      device.save!
    end
    Device.find(:all, :conditions => "device_type = 'Halo Gateway'").each do |device|
      device.device_type_id = gw.id
      device.save!
    end
  end

  def self.down
  end
end
