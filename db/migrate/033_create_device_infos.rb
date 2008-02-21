class CreateDeviceInfos < ActiveRecord::Migration
  def self.up
    create_table :device_infos do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :serial_number, :string
      t.column :mac_address, :string
      t.column :vendor, :string
      t.column :model, :string
      t.column :kind, :string
      t.column :kind_id, :integer
      #t.timestamps
    end
  end

  def self.down
    drop_table :device_infos
  end
end
