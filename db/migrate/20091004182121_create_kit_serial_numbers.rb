class CreateKitSerialNumbers < ActiveRecord::Migration
  def self.up
    create_table :kit_serial_numbers do |t|
      t.column :id, :primary_key, :null => false 
	  t.column :serial_number,:text
	  t.column :user_id,:integer
      t.timestamps

    end
  end

  def self.down
    drop_table :kit_serial_numbers
  end
end
