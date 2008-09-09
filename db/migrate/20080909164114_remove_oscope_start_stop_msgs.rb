class RemoveOscopeStartStopMsgs < ActiveRecord::Migration
  def self.up
    drop_table :oscope_start_stop_msgs
  end

  def self.down
    create_table :oscope_start_stop_msgs do |t|
      t.column :id, :primary_key, :null => false
      t.column :start_stop, :string
      t.column :capture_reason, :string
      t.column :source_mote_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :user_id, :integer
    end
  end
end
