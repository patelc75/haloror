class CreateVitalScans < ActiveRecord::Migration
  def self.up
    create_table :vital_scans do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      #t.timestamps
    end
  end

  def self.down
    drop_table :vital_scans
  end
end
