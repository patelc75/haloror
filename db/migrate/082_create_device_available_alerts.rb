class CreateDeviceAvailableAlerts < ActiveRecord::Migration
  def self.up
    create_table :device_available_alerts do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer, :null => false, :references => 'devices'
      t.column :created_at, :datetime, :null => false
    end

    add_index 'device_available_alerts', %w(device_id), :name => 'device_available_alerts_device_id_idx'
  end

  def self.down
    drop_table :device_available_alerts if
      ActiveRecord::Base.connection.tables.include?(:device_available_alerts)
        
    remove_index :device_available_alerts, :device_available_alerts_device_id_idx
  end
end
