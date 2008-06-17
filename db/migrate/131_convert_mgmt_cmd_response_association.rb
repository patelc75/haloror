class ConvertMgmtCmdResponseAssociation < ActiveRecord::Migration
  def self.up
    remove_column :mgmt_responses, :mgmt_cmd_id
    add_column :mgmt_cmds, :mgmt_response_id, :integer
  end

  def self.down
    add_column :mgmt_response, :mgmt_cmd_id, :integer
    remove_column :mgmt_cmds, :mgmt_response_id
  end
end