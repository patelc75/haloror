class AddIndexLostData < ActiveRecord::Migration
  def self.up
    add_index :lost_datas, [:user_id, :end_time, :begin_time]
  end

  def self.down
    remove_index :lost_datas, [:user_id, :end_time, :begin_time]
  end
end
