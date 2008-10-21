class AddIndexDeviceInfosOnDeviceId < ActiveRecord::Migration
  def self.up
    add_index :device_infos, :device_id
  end

  def self.down
    remove_index :device_infos, :device_id
  end
end
