class AddColumnsToDialUpStatuses < ActiveRecord::Migration
  def self.up
    add_column :dial_up_statuses, :lowest_connect_rate,             :integer
    add_column :dial_up_statuses, :lowest_connect_timestamp,        :datetime
    add_column :dial_up_statuses, :longest_dial_duration_sec,       :integer
    add_column :dial_up_statuses, :longest_dial_duration_timestamp, :datetime
  end

  def self.down
    remove_columns :dial_up_statuses, :lowest_connect_rate, :lowest_connect_timestamp
    remove_columns :dial_up_statuses, :longest_dial_duration_sec, :longest_dial_duration_timestamp
  end
end
