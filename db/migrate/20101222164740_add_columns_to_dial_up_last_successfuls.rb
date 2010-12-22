# 
#  Wed Dec 22 22:28:13 IST 2010, ramonrails
#   * https://redmine.corp.halomonitor.com/issues/3901
#   * WARNING: These columns also stay in dial_up_statuses. Should not be confused with the new ones
class AddColumnsToDialUpLastSuccessfuls < ActiveRecord::Migration
  def self.up
    add_column :dial_up_last_successfuls, :lowest_connect_rate,             :integer
    add_column :dial_up_last_successfuls, :lowest_connect_timestamp,        :datetime
    add_column :dial_up_last_successfuls, :longest_dial_duration_sec,       :integer
    add_column :dial_up_last_successfuls, :longest_dial_duration_timestamp, :datetime
  end

  def self.down
    #   * we will never need to remove these, but the code is here, if we do
    # remove_columns :dial_up_last_successfuls, :lowest_connect_rate, :lowest_connect_timestamp
    # remove_columns :dial_up_last_successfuls, :longest_dial_duration_sec, :longest_dial_duration_timestamp
  end
end
