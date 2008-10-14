class AddParam1ToMgmtCmd < ActiveRecord::Migration
  def self.up
    add_column :mgmt_cmds, :param1, :integer, :limit => 4
  end
  
  def self.down
    remove_column :mgmt_cmds, :param1
  end
end
