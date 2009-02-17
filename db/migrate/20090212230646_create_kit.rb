class CreateKit < ActiveRecord::Migration
  def self.up
    create_table :kits, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.timestamps
    end
    create_table :devices_kits, :id => false, :force => true do |t|
      t.column :kit_id, :integer, :null => false
      t.column :device_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :devices_kits
    drop_table :kits
  end
end
