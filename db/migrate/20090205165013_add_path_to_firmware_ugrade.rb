class AddPathToFirmwareUgrade < ActiveRecord::Migration
  def self.up
    add_column :firmware_upgrades, :path, :string
  end

  def self.down
    remove_column :firmware_upgrades, :path
  end
end
