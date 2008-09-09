class CreateOscopeMsgs < ActiveRecord::Migration
  def self.up
    create_table :oscope_msgs do |t|
      t.column :id, :primary_key, :null => false
      t.column :timestamp, :timestamp_with_time_zone
      t.column :channel_num, :integer
    end
  end

  def self.down
    drop_table :oscope_msgs
  end
end
