class CreateStrapOnAlert < ActiveRecord::Migration
  def self.up
    create_table :strap_on_alerts do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer, :null => false, :references => 'devices'
      t.column :created_at, :datetime, :null => false
    end
    add_index :strap_on_alerts, :device_id

    end

    def self.down
      remove_index :strap_on_alerts, :device_id
      drop_table :strap_on_alerts
    end
end
