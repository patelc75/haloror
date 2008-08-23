class AddUserIdToMgmtCmd < ActiveRecord::Migration
  def self.up
    add_column :mgmt_cmds, :created_by, :integer
  end

  def self.down
    remove_column :mgmt_cmds, :created_by
  end
end
