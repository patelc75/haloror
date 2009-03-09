class PopulateDeviceTypeModelRevision < ActiveRecord::Migration
  def self.up
    chest_strap_type = DeviceType.find_by_device_type('Chest Strap')
    unless chest_strap_type
      chest_strap_type = DeviceType.new(:device_type => 'Chest Strap', :mac_address_type => 0)
      chest_strap_type.save!
    end
    
    gateway_type = DeviceType.find_by_device_type('Gateway')
    unless gateway_type
      gateway_type = DeviceType.new(:device_type => 'Gateway', :mac_address_type => 1)
      gateway_type.save!
    end
    
    nc_type = DeviceType.find_by_device_type('Network Coordinator')
    unless chest_strap_type
      nc_type = DeviceType.new(:device_type => 'Network Coordinator', :mac_address_type => 0)
      nc_type.save!
    end
    
    pkg_type = DeviceType.find_by_device_type('MyHalo Top Assembly')
    unless pkg_type
      pkg_type = DeviceType.new(:device_type => 'MyHalo Top Assembly', :mac_address_type => 0)
      pkg_type.save!
    end
    
    repeater_type = DeviceType.find_by_device_type('Repeater')
    unless repeater_type
      repeater_type = DeviceType.new(:device_type => 'Repeater', :mac_address_type => 0)
      repeater_type.save!
    end
    
    chest_strap_model = DeviceModel.find_by_device_type_id(chest_strap_type.id)
    unless chest_strap_model
      chest_strap_model = DeviceModel.new(:device_type_id => chest_strap_type.id, :part_number => '22001001')
      chest_strap_model.save!
    end
    
    gateway_model = DeviceModel.find_by_device_type_id(gateway_type.id)
    unless chest_strap_model
      gateway_model = DeviceModel.new(:device_type_id => gateway_type.id, :part_number => '22001005')
      gateway_model.save!
    end
    
    chest_strap_revision = DeviceRevision.find_by_device_model_id(chest_strap_model.id)
    unless chest_strap_revision
      chest_strap_revision = DeviceRevision.new(:device_model_id => chest_strap_model.id, :revision => 'D')
      chest_strap_revision.save!
    end
    
    gateway_revision = DeviceRevision.find_by_device_model_id(gateway_model.id)
    unless chest_strap_revision
      gateway_revision = DeviceRevision.new(:device_model_id => gateway_model.id, :revision => 'C')
      gateway_revision.save!
    end
    
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
