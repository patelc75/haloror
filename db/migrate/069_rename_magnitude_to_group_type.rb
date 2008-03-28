class RenameMagnitudeToGroupType < ActiveRecord::Migration
  def self.up
    rename_column :alert_groups, :magnitude, :group_type
  end

  def self.down
    rename_column :alert_groups, :group_type, :magnitude
  end
end
