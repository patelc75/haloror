class AddEventIdToCallCenterSteps < ActiveRecord::Migration
  def self.up
    add_column :call_center_steps, :event_id, :integer
    add_column :call_center_steps, :step_num, :integer
  end

  def self.down
    remove_column :call_center_steps, :event_id
  end
end
