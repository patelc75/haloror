class OnlineStoreFlagShiftedToDeviceRevision < ActiveRecord::Migration
  def self.up
    add_column :device_revisions, :online_store, :boolean
    remove_column :device_types, :online_store
    
    puts "Updating data for specific device type revisions..."
    ["Chest Strap", "Halo Complete", "Belt Clip", "Halo Clip"].each do |data|
      device = DeviceType.find_by_device_type(data)
      unless device.blank?
        revision = device.latest_model_revision
        unless revision.blank?
          revision.online_store = true
          revision.save
        end
      end
    end
    puts "Update is complete."
  end

  def self.down
    remove_column :device_revisions, :online_store
    add_column :device_types, :online_store, :boolean
  end
end
