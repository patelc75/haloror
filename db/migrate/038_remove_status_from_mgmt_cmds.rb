class RemoveStatusFromMgmtCmds < ActiveRecord::Migration
  def self.up
    remove_column :mgmt_cmds, :status
  end

  def self.down
    add_column :mgmt_cmds, :status, :string
  end
end
