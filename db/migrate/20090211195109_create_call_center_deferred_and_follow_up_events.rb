class CreateCallCenterDeferredAndFollowUpEvents < ActiveRecord::Migration
  def self.up
    create_table :call_center_deferreds, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :user_id, :integer
      t.column :event_id, :integer
      t.column :call_center_session_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :pending, :boolean
    end
    
    create_table :call_center_follow_ups, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :user_id, :integer
      t.column :event_id, :integer
      t.column :call_center_session_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
    end
  end

  def self.down
    drop_table :call_center_follow_ups
    drop_table :call_center_deferreds
  end
end
