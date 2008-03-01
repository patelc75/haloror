class CreateOutageAlerts < ActiveRecord::Migration
  def self.up
    create_table "outage_alerts", :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer, :null => false, :references => 'devices'
      t.column :number_attempts, :integer, :null => false, :default => 1
      t.column :reconnected_at,            :datetime
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end

    add_index 'outage_alerts', %w(device_id), :name => 'outage_alerts_device_id_idx'

    ## This index is used to help us quickly identify prior alerts for
    ## devices that have since come online
    execute "create index outage_alerts_outage_idx on outage_alerts(device_id) where reconnected_at is null"
  end

  def self.down
    drop_table "outage_alerts"
  end
end
