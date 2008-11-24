class RecreateCallCenterSteps < ActiveRecord::Migration
  def self.up
    drop_table :call_center_steps
    create_table :call_center_steps, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :instruction, :text
      t.column :script, :text
      t.column :answer, :text
      t.column :updated_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
      t.column :call_center_steps_group_id, :integer
    end
    
    create_table :call_center_steps_groups, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :event_id, :integer
      t.column :updated_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone      
    end
  end

  def self.down
    drop_table :call_center_steps_groups
  end
end
