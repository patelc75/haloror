class NewDeviceTypeForBeltClip < ActiveRecord::Migration
  def self.up
  	  belt_clip_type = DeviceType.new(:device_type => 'Belt Clip', :mac_address_type => 0)
      belt_clip_type.save!
      belt_clip_model = DeviceModel.new(:device_type_id => belt_clip_type.id, :part_number => '22001007')
      belt_clip_model.save!
      belt_clip_revision = DeviceRevision.new(:device_model_id => belt_clip_model.id, :revision => 'A')
      belt_clip_revision.save!
  end

  def self.down
  end
end

#Email to Hugh, Jerry, and Chris
#part number (eg. 22001002-1) - will pick some random value until somebody gets back to me
#revision (eg. C/C , H/D, Tmote Sky) - will assume A
#mac_address_type (will assume 0 since CS is 0)
#Serial number  (eg. H110000023) - will assume H4xxxxxxxx until a decision is made