class RenameAlertGroupsIdInAlertTypes < ActiveRecord::Migration
  def self.up
    rename_column :alert_types, :alert_groups_id, :alert_group_id
  end

  def self.down
    rename_column :alert_types, :alert_group_id, :alert_groups_id
  end
end
