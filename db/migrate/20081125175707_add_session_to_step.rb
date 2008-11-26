class AddSessionToStep < ActiveRecord::Migration
  def self.up
    add_column :call_center_steps, :call_center_session_id, :integer
    add_column :call_center_steps, :call_center_group_id, :integer
    remove_column :call_center_steps, :call_center_steps_group_id
  end

  def self.down
  end
end
