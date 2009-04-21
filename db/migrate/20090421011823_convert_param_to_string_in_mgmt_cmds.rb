class ConvertParamToStringInMgmtCmds < ActiveRecord::Migration
  def self.up
  	change_column :mgmt_cmds, :param1, :string
  end

  def self.down
  	change_column :mgmt_cmds, :param1, :integer
  end
end
