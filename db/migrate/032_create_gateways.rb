class CreateGateways < ActiveRecord::Migration
  def self.up
    create_table :gateways do |t|
      t.column :id, :primary_key, :null => false
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
    drop_table :gateways
  end
end
