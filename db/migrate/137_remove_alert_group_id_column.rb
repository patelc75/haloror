class RemoveAlertGroupIdColumn < ActiveRecord::Migration
  def self.up
    remove_column :alert_types, :alert_group_id
  end

  def self.down
    add_column :alert_types, :alert_group_id
  end
end
