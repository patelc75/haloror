class AddMoreColumnsToVital < ActiveRecord::Migration
  def self.up
	add_column :vitals, :timestamp, :timestamp_with_time_zone
    add_column :vitals, :user_id, :integer
  end

  def self.down
	remove_column :vitals, :user_id
    remove_column :vitals, :timestamp
  end
end
