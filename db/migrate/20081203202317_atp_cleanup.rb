class AtpCleanup < ActiveRecord::Migration
  def self.up
    drop_table :device_types_work_orders
    create_table :device_revisions_work_orders, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :work_order_id, :integer
      t.column :device_revision_id, :integer
      t.column :num, :integer
      t.column :starting_mac_address, :string
      t.column :total_mac_addresses, :integer
      t.column :current_mac_address, :string
      t.column :starting_serial_num, :string
      t.column :total_serial_nums, :integer
      t.column :current_serial_num, :string
      t.column :updated_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
  end

  def self.down
    drop_table :device_revisions_work_orders
  end
end
