class AddHashKeyToFirmwareUpgrades < ActiveRecord::Migration
  def self.up
    ## hash_key is used as an example on how to authenticate from the gateway
    add_column :firmware_upgrades, :hash_key, :string, :null => false
  end

  def self.down
    remove_column :firmware_upgrades, :hash_key
  end
end
