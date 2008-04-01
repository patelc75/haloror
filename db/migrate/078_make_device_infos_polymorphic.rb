class MakeDeviceInfosPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :device_infos, :kind, :device_info_type
    rename_column :device_infos, :kind_id, :device_info_id
  end

  def self.down
    rename_column :device_infos, :device_info_type, :kind
    rename_column :device_infos, :device_info_id, :kind_id
  end
end
