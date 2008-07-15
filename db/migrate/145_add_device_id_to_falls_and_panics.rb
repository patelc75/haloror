class AddDeviceIdToFallsAndPanics < ActiveRecord::Migration
  def self.up
    add_column :falls, :device_id, :integer
    add_column :panics, :device_id, :integer
  end

  def self.down
    remove_column :falls, :device_id
    remove_column :panics, :device_id
  end
end
