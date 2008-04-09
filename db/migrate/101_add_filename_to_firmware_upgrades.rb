class AddFilenameToFirmwareUpgrades < ActiveRecord::Migration
  def self.up
    add_column :firmware_upgrades, :filename, :string
  end

  def self.down
    remove_column :firmware_upgrades, :filename
  end
end
