class AddGroupIdToDialUps < ActiveRecord::Migration
  def self.up
    add_column :dial_ups, :group_id, :integer
  end

  def self.down
    remove_column :dial_ups, :group_id
  end
end
