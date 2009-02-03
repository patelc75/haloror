class MoveSerialPrefixToSerialPrefixTable < ActiveRecord::Migration
  def self.up
    remove_column :device_types, :serial_number_prefix
    create_table :serial_number_prefixes, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :prefix, :string, :null => false
      t.column :device_type_id, :integer
      t.timestamps
    end
  end

  def self.down
  end
end
