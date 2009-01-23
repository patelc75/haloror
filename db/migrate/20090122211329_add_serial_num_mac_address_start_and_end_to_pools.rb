class AddSerialNumMacAddressStartAndEndToPools < ActiveRecord::Migration
  def self.up
    remove_column :pools, :type
    add_column :pools, :starting_serial_number, :string
    add_column :pools, :ending_serial_number,   :string
    add_column :pools, :starting_mac_address,   :string
    add_column :pools, :ending_mac_address,     :string
  end

  def self.down
    remove_column :pools, :starting_serial_number, :string
    remove_column :pools, :ending_serial_number,   :string
    remove_column :pools, :starting_mac_address,   :string
    remove_column :pools, :ending_mac_address,     :string
    add_column :pools, :type, :string
  end
end
