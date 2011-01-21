class MoreDeviceInfosColumns < ActiveRecord::Migration
  def self.up
    add_column :device_infos, :created_at, :datetime
    add_column :device_infos, :software_version_new, :boolean
    add_column :device_infos, :software_version_current, :boolean
  end

  def self.down
    remove_columns :device_infos, :created_at, :software_version_new, :software_version_current
  end
end
