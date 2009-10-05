class CreateStrapNotWornScans < ActiveRecord::Migration
  def self.up
    create_table :strap_not_worn_scans do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer
      t.column :timestamp, :datetime
    end

	add_index :strap_not_worn_scans, [:user_id,:timestamp], :unique => false

  end

  def self.down
    drop_table :strap_not_worn_scans
  end
end
