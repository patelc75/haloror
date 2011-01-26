class AddTimestampToDialUpStatus < ActiveRecord::Migration
  def self.up
    add_column :dial_up_statuses, :timestamp, :datetime
    add_column :dial_up_last_successfuls, :timestamp, :datetime
  end

  def self.down
    remove_column :dial_up_statuses, :timestamp
    remove_column :dial_up_last_successfuls, :timestamp
  end
end
