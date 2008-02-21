class AddPendingToMgmtCmds < ActiveRecord::Migration
  def self.up
    #remove_column :mgmt_cmds, :status
    
    add_column :mgmt_cmds, :pending, :boolean, :default => true
  end

  def self.down
    remove_column :mgmt_cmds, :pending
  end
end
