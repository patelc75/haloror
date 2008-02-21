class AddStatusToMgmtCmds < ActiveRecord::Migration
  def self.up
    add_column :mgmt_cmds, :status, :string
  end

  def self.down
    remove_column :mgmt_cmds, :status
  end
end
