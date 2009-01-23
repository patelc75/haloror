class CreatePoolForSerialNumbersMacAddresses < ActiveRecord::Migration
  def self.up
    create_table :pools, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :size, :integer, :null => false
      t.column :type, :string, :null => false
      t.column :created_by, :integer
      t.column :created_at, :timestamp_with_time_zone
      t.column :updated_at, :timestamp_with_time_zone
    end
    
    create_table :pool_mappings, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :serail_number, :string, :null => false
      t.column :mac_address, :string, :null => false
      t.column :pool_id, :integer, :null => false
      t.column :created_at, :timestamp_with_time_zone
      t.column :updated_at, :timestamp_with_time_zone
    end
  end

  def self.down
    drop_table :pool_mappings
    drop_table :pools
  end
end
