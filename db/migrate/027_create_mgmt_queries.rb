class CreateMgmtQueries < ActiveRecord::Migration
  def self.up
    create_table :mgmt_queries do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :timestamp_device, :timestamp_with_time_zone
      t.column :timestamp_server, :timestamp_with_time_zone
      t.column :poll_rate, :integer
      #t.timestamps
    end
  end

  def self.down
    drop_table :mgmt_queries
  end
end
