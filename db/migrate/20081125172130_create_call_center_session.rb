class CreateCallCenterSession < ActiveRecord::Migration
  def self.up
    create_table :call_center_sessions, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :event_id, :integer
      t.column :updated_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
    end
    
    add_column :call_center_steps_groups, :call_center_session_id, :integer
  end

  def self.down
    remove_column :call_center_steps_groups, :call_center_session_id
    drop_table :call_center_sessions
  end
end
