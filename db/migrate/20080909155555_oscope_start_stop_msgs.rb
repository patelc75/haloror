class OscopeStartStopMsgs < ActiveRecord::Migration
  def self.up
    create_table :oscope_start_stop_msgs do |t|
      t.column :id, :primary_key, :null => false
      t.column :start_stop, :string
      t.column :capture_reason, :string
      t.column :source_mote_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :oscope_start_stop_msgs
  end
end
