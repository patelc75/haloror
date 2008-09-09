class CreateOscopeStartMsgStopMsg < ActiveRecord::Migration
  def self.up
    create_table :oscope_start_msgs do |t|
      t.column :id, :primary_key, :null => false
      t.column :capture_reason, :string
      t.column :source_mote_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :user_id, :integer
    end
    
    create_table :oscope_stop_msgs do |t|
      t.column :id, :primary_key, :null => false
      t.column :capture_reason, :string
      t.column :source_mote_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :oscope_stop_msgs
    drop_table :oscope_start_msgs
  end
end
