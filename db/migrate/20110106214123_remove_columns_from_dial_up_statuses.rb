class RemoveColumnsFromDialUpStatuses < ActiveRecord::Migration
  def self.up
    remove_columns :dial_up_statuses, :lowest_connect_rate, :lowest_connect_timestamp
    remove_columns :dial_up_statuses, :longest_dial_duration_sec, :longest_dial_duration_timestamp
  end

  def self.down
    # nothing here. we never want these columns back
  end
end
