class AddParam2AndParam3ToMgmtCmds < ActiveRecord::Migration
  def self.up
  	add_column :mgmt_cmds, :param2, :string
  	add_column :mgmt_cmds, :param3, :string
  end

  def self.down
  	remove_column :mgmt_cmds, :param2
  	remove_column :mgmt_cmds, :param3
  end
end
