class AddStatusResolvedToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :accepted_by, :integer
    add_column :events, :accepted_at, :timestamp_with_time_zone
    
    add_column :events, :resolved_by, :integer
    add_column :events, :resolved_at, :timestamp_with_time_zone
  end

  def self.down
    remove_column :events, :accepted_by
    remove_column :events, :accepted_at
    
    remove_column :events, :resolved_by
    remove_column :events, :resolved_at
  end
end
