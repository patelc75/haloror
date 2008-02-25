class AddMgmtCmdIdToMgmtQueries < ActiveRecord::Migration
  def self.up
    add_column :mgmt_queries, :mgmt_cmd_id, :integer
  end

  def self.down
    remove_column :mgmt_queries, :mgmt_cmd_id
  end
end
