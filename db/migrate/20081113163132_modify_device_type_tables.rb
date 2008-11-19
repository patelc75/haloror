class ModifyDeviceTypeTables < ActiveRecord::Migration
  def self.up
    create_table :device_models, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_type_id, :integer
      t.column :part_number, :string
      t.column :model, :string
      t.column :updated_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    create_table :device_revisions, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_model_id, :integer
      t.column :revision, :string
      t.column :updated_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :comments, :string
    end
    
    add_column :devices, :device_revision_id, :integer
    
    remove_column :devices, :device_type
    remove_column :devices, :device_type_id
    remove_column :device_types, :model
    remove_column :device_types, :part_number
    
    rename_column :device_types, :type, :device_type
    
    rename_column :device_types_work_orders, :update_at, :updated_at
    rename_column :device_types, :update_at, :updated_at
    rename_column :work_orders, :update_at, :updated_at
    rename_column :atp_test_results, :update_at, :updated_at
    rename_column :atp_test_results_work_orders, :update_at, :updated_at
    rename_column :rmas, :update_at, :updated_at
    rename_column :atp_test_results_rmas, :update_at, :updated_at
    rename_column :atp_items, :update_at, :updated_at
    rename_column :atp_item_results, :update_at, :updated_at
    rename_column :atp_items_device_types, :update_at, :updated_at
    rename_column :atp_item_results_atp_test_results, :update_at, :updated_at
    
  end

  def self.down
  end
end
