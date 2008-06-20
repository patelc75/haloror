class AddStrapOffAlert < ActiveRecord::Migration
  def self.up
    create_table :strap_off_alerts do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer, :null => false, :references => 'devices'
      t.column :created_at, :datetime, :null => false
      t.column :update_at, :datetime
      t.column :number_attempts, :integer, :null => false, :default => 1
    end

    add_index :strap_off_alerts, :device_id

  end

  def self.down
    remove_index :strap_off_alerts, :device_id
    drop_table :strap_off_alerts
  end
end
