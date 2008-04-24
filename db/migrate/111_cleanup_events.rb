class CleanupEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :alert_type_id
    remove_column :events, :accepted_by
    remove_column :events, :accepted_at
    remove_column :events, :resolved_by
    remove_column :events, :resolved_at
  end

  def self.down
    add_column :events, :alert_type_id, :integer
    add_column :events, :accepted_by, :integer
    add_column :events, :accepted_at, :timestamp_with_time_zone
    add_column :events, :resolved_by, :resolved_by
    add_column :events, :resolved_at, :timestamp_with_time_zone
  end
end
