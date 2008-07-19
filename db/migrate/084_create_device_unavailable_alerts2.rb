class CreateDeviceUnavailableAlerts2 < ActiveRecord::Migration
  def self.up
    drop_table "device_unavailable_alerts" rescue Exception
    ## Note: Maintain exact same table structure as outage_alerts
    create_table "device_unavailable_alerts", :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer, :null => false, :references => 'devices'
      t.column :number_attempts, :integer, :null => false, :default => 1
      t.column :reconnected_at,            :datetime
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end

    add_index 'device_unavailable_alerts', %w(device_id), :name => 'device_unavailable_alerts_device_id_idx'

    ## This index is used to help us quickly identify prior alerts for
    ## users that have since come online
    execute "create index device_unavailable_alerts_device_unavailable_idx on device_unavailable_alerts(device_id) where reconnected_at is null"
  end

  def self.down
    drop_table "device_unavailable_alerts" rescue Exception

    create_table "device_unavailable_alerts", :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer, :null => false, :references => 'users'
      t.column :number_attempts, :integer, :null => false, :default => 1
      t.column :reconnected_at,            :datetime
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end

    add_index 'device_unavailable_alerts', %w(user_id), :name => 'device_unavailable_alerts_user_id_idx'

    ## This index is used to help us quickly identify prior alerts for
    ## users that have since come online
    execute "create index device_unavailable_alerts_device_unavailable_idx on device_unavailable_alerts(user_id) where reconnected_at is null"
  end
end
