class AddHeaderToCallCenterSteps < ActiveRecord::Migration
  def self.up
    add_column :call_center_steps, :header, :text
  end

  def self.down
    remove_column :call_center_steps, :header
  end
end
