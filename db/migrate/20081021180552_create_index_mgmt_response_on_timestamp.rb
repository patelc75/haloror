class CreateIndexMgmtResponseOnTimestamp < ActiveRecord::Migration
  def self.up
    add_index :mgmt_responses, :timestamp_server
  end

  def self.down
    remove_index :mgmt_responses, :timestamp_server
  end
end
