class CreateMgmtCmds < ActiveRecord::Migration
  def self.up
    create_table :mgmt_cmds do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :user_id, :integer
      t.column :cmd_type, :string
      t.column :timestamp_initiated, :timestamp_with_time_zone
      t.column :timestamp_sent, :timestamp_with_time_zone
      t.column :originator, :string
      #t.timestamps
    end
  end

  def self.down
    drop_table :mgmt_cmds
  end
end
