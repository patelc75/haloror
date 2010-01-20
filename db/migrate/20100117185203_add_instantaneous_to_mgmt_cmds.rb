class AddInstantaneousToMgmtCmds < ActiveRecord::Migration
  def self.up
  	add_column :mgmt_cmds,:instantaneous,:boolean
  end

  def self.down
  	remove_column :mgmt_cmds,:instantaneous
  end
end
