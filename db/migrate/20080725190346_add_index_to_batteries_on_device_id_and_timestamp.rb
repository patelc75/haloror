class AddIndexToBatteriesOnDeviceIdAndTimestamp < ActiveRecord::Migration
  def self.up
    add_index :batteries, [:timestamp, :device_id]
  end

  def self.down
    add_index :batteries, [:timestamp, :device_id]
  end
end
