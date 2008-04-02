class CreateDeviceAlerts < ActiveRecord::Migration
  def self.up
    create_table :device_alerts do |t|
      t.column :id, :primary_key, :null => false
    end
  end

  def self.down
    drop_table :device_alerts
  end
end