class ModifyFirmwareUpgrades < ActiveRecord::Migration
  def self.up
    remove_column :firmware_upgrades, :hash_key
    add_column    :firmware_upgrades, :description, :text
    add_column    :firmware_upgrades, :date_added, :date    
  end

  def self.down
    remove_column :firmware_upgrades, :date_added
    remove_column :firmware_upgrades, :description
    add_column    :firmware_upgrades, :hash_key, :string, :null => false
  end
end
