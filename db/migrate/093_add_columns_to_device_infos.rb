class AddColumnsToDeviceInfos < ActiveRecord::Migration
  def self.up
    add_column :device_infos, :user_id, :integer
    add_column :device_infos, :hardware_version, :string
    add_column :device_infos, :software_version, :string
    add_column :device_infos, :mgmt_response_id, :integer
  end

  def self.down
    remove_column :device_infos, :user_id
    remove_column :device_infos, :hardware_version
    remove_column :device_infos, :software_version
    remove_column :device_infos, :mgmt_response_id
  end
end
