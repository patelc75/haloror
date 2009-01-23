class RemoveColumnsFromRevisionsWorkOrders < ActiveRecord::Migration
  def self.up
    remove_column :device_revisions_work_orders, :num
    remove_column :device_revisions_work_orders, :starting_mac_address
    remove_column :device_revisions_work_orders, :total_mac_addresses
    remove_column :device_revisions_work_orders, :current_mac_address
    remove_column :device_revisions_work_orders, :starting_serial_num
    remove_column :device_revisions_work_orders, :total_serial_nums
    remove_column :device_revisions_work_orders, :current_serial_num
  end

  def self.down
    add_column :device_revisions_work_orders, :num, :integer
    add_column :device_revisions_work_orders, :starting_mac_address, :string
    add_column :device_revisions_work_orders, :total_mac_addresses, :string
    add_column :device_revisions_work_orders, :current_mac_address, :string
    add_column :device_revisions_work_orders, :starting_serial_num, :string
    add_column :device_revisions_work_orders, :total_serial_nums, :string
    add_column :device_revisions_work_orders, :current_serial_num, :string
  end
end
