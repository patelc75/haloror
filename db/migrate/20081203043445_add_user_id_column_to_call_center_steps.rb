class AddUserIdColumnToCallCenterSteps < ActiveRecord::Migration
  def self.up
    add_column :call_center_steps, :user_id, :integer
  end

  def self.down
    remove_column :call_center_steps, :user_id
  end
end
