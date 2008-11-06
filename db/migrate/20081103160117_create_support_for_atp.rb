class CreateSupportForAtp < ActiveRecord::Migration
  def self.up
    create_table :work_orders, :force => true do |t|
      t.column :id, :primary_key, :null => false 
      t.column :completed_on, :timestamp_with_time_zone
      t.column :work_order_num, :string
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :device_types, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :type, :string
      t.column :model, :string
      t.column :part_number, :string
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :device_types_work_orders, :id => false, :force => true do |t|
      t.column :work_order_id, :integer
      t.column :device_type_id, :integer
      t.column :num, :integer
      t.column :starting_mac_address, :string
      t.column :total_mac_addresses, :integer
      t.column :current_mac_address, :string
      t.column :starting_serial_num, :string
      t.column :total_serial_nums, :integer
      t.column :current_serial_num, :string
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :atp_test_results, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :result, :boolean
      t.column :device_id, :integer
      t.column :operator_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :atp_test_results_work_orders, :id => false, :force => true do |t|
      t.column :atp_test_result_id, :integer
      t.column :work_order_id, :integer
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :rmas, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :completed_on, :timestamp_with_time_zone
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :atp_test_results_rmas, :id => false, :force => true do |t|
      t.column :atp_test_result_id, :integer
      t.column :rma_id, :integer
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :atp_items, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :range_low, :integer
      t.column :range_high, :integer
      t.column :description, :string
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :atp_item_results, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :atp_item_id, :integer
      t.column :result, :boolean
      t.column :device_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :result_value, :boolean
      t.column :operator_id, :integer
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :atp_items_device_types, :id => false, :force => true do |t|
      t.column :atp_item_id, :integer
      t.column :device_type_id, :integer
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    create_table :atp_item_results_atp_test_results, :id => false, :force => true do |t|
      t.column :atp_item_result_id, :integer
      t.column :atp_test_result_id, :integer
      t.column :update_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    add_column :devices, :device_type_id, :integer
    add_column :devices, :active, :boolean
    add_column :devices, :mac_address, :string
  end

  def self.down
  end
end
