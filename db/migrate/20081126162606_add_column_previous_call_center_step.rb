class AddColumnPreviousCallCenterStep < ActiveRecord::Migration
  def self.up
    add_column :call_center_steps, :previous_call_center_step_id, :integer
  end

  def self.down
    remove_column :call_center_steps, :previous_call_center_step_id
  end
end
