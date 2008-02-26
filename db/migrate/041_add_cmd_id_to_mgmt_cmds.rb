class AddCmdIdToMgmtCmds < ActiveRecord::Migration
  def self.up
    add_column :mgmt_cmds, :cmd_id, :integer
  end

  def self.down
    remove_column :mgmt_cmds, :cmd_id
  end
end
