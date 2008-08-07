class AddColumnsToMgmtCmds < ActiveRecord::Migration
  def self.up
    add_column :mgmt_cmds, :attempts_no_ack, :integer, :limit => 1
    add_column :mgmt_cmds, :pending_on_ack, :boolean
    add_column :mgmt_queries, :cycle_num, :integer, :limit => 1      
  end

  def self.down
    remove_column :mgmt_cmds, :attempts_no_ack
    remove_column :mgmt_cmds, :pending_on_ack
    remove_column :mgmt_queries, :cycle_num
  end
end