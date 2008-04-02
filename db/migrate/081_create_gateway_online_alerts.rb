class CreateGatewayOnlineAlerts < ActiveRecord::Migration
  def self.up
    create_table :gateway_online_alerts do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer, :null => false, :references => 'devices'
      t.column :created_at, :datetime, :null => false
    end

    add_index 'gateway_online_alerts', %w(device_id), :name => 'gateway_online_alerts_device_id_idx'

  end

  def self.down
    drop_table :gateway_online_alerts
  end
end
