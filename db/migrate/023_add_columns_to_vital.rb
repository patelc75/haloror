class AddColumnsToVital < ActiveRecord::Migration
  def self.up
    add_column :vitals, :heartrate,   :integer, :default => nil, :limit => 1
    add_column :vitals, :hrv,         :integer, :default => nil, :limit => 1
    add_column :vitals, :activity,    :integer, :default => nil, :limit => 4
    add_column :vitals, :orientation, :integer, :default => nil, :limit => 1

    add_column :vitals, :timestamp, :timestamp_with_time_zone
    add_column :vitals, :user_id, :integer
  end

  def self.down
    remove_column :vitals, :heartrate
    remove_column :vitals, :hrv
    remove_column :vitals, :activity
    remove_column :vitals, :orientation
    remove_column :vitals, :user_id
    remove_column :vitals, :timestamp
  end
end
