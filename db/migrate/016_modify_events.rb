class ModifyEvents < ActiveRecord::Migration
  def self.up
	add_column :events, :timestamp, :timestamp_with_time_zone
  end

  def self.down
  end
end
