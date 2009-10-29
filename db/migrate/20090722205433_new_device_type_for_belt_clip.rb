class NewDeviceTypeForBeltClip < ActiveRecord::Migration
  def self.up
  	  belt_clip_type = DeviceType.find_by_device_type_and_mac_address_type('Belt Clip',0)
  	  if not belt_clip_type
  	  	belt_clip_type = DeviceType.new(:device_type => 'Belt Clip', :mac_address_type => 0)
      	belt_clip_type.save!
      end
      
      belt_clip_model = DeviceModel.find_by_device_type_id_and_part_number(belt_clip_type.id,'22001007')
      if not belt_clip_model
      	belt_clip_model = DeviceModel.new(:device_type_id => belt_clip_type.id, :part_number => '22001007')
      	belt_clip_model.save!
  	  end
      
  	  belt_clip_revision = DeviceRevision.find_by_device_model_id_and_revision(belt_clip_model.id,'A')
  	  if not belt_clip_revision
  	  	belt_clip_revision = DeviceRevision.new(:device_model_id => belt_clip_model.id, :revision => 'A')
      	belt_clip_revision.save!
  	  end
  	  
  end

  def self.down
  end
end

#Email to Hugh, Jerry, and Chris
#part number (eg. 22001002-1) - will pick some random value until somebody gets back to me
#revision (eg. C/C , H/D, Tmote Sky) - will assume A
#mac_address_type (will assume 0 since CS is 0)
#Serial number  (eg. H110000023) - will assume H4xxxxxxxx until a decision is made