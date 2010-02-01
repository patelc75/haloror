class DeviceTypesOnlineStoreFlag < ActiveRecord::Migration
  def self.up
    # new column to identify if this product apears on online store.
    # TODO: should this be decided in device_revision instead?
    #
    add_column :device_types, :online_store, :boolean
    
    # migrate existing data for specific names only
    # => we shifted the flag to device_revisions. This migration is no longer required.
    #
    # ["Chest Strap", "Halo Complete", "Belt Clip"].each do |data|
    #   device = DeviceType.find_by_device_type(data)
    #   unless device.blank?
    #     device.online_store = true
    #     device.save
    #   end
    # end
  end

  def self.down
    remove_column :device_types, :online_store
  end
end
