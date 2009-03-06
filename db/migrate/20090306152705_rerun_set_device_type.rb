class RerunSetDeviceType < ActiveRecord::Migration
  def self.up
    chest_strap_revision = DeviceRevision.find(:first, :include => {:device_model => :device_type},
                                               :order => 'device_revisions.id desc',
                                               :conditions => "device_types.device_type = 'Chest Strap'")
    gateway_revision = DeviceRevision.find(:first, :include => {:device_model => :device_type},
                                           :order => 'device_revisions.id desc',
                                           :conditions => "device_types.device_type = 'Gateway'")                                               
    Device.find(:all, :conditions =>"serial_number like 'H1%'").each do |device|
      device.device_revision_id = chest_strap_revision.id if !chest_strap_revision.nil?
      device.save!
    end
    Device.find(:all, :conditions =>"serial_number like 'H2%'").each do |device|
      device.device_revision_id = gateway_revision.id if !gateway_revision.nil?
      device.save!
    end
  end

  def self.down
  end
end
