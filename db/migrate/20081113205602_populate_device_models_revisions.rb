class PopulateDeviceModelsRevisions < ActiveRecord::Migration
  def self.up
    #create devicetypes
    #create device_models
    #create device_revisions
    #assign device_revision to device
    device = DeviceType.find(1)
    device.device_type = 'Chest Strap'
    device.save!
    
    device = DeviceType.find(2)
    device.device_type = 'Gateway'
    device.save!
    
    DeviceModel.create(:device_type_id => 1, :part_number => '22001001')
    DeviceModel.create(:device_type_id => 2, :part_number => '22001005')
    
    DeviceRevision.create(:device_model_id => 1, :revision => 'C')
    DeviceRevision.create(:device_model_id => 2, :revision => 'B')
    
  end

  def self.down
  end
end
