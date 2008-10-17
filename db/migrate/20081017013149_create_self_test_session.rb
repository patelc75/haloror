class CreateSelfTestSession < ActiveRecord::Migration
  def self.up
    create_table :self_test_sessions do |t|
      t.column :id, :primary_key, :null => false
      t.column :created_at, :timestamp_with_time_zone
      t.column :created_by, :integer
      t.column :user_id, :integer
      t.column :completed_on, :timestamp_with_time_zone
    end
    add_column :self_test_steps, :self_test_session_id, :integer
  end

  def self.down
    remove_column :self_test_steps, :self_test_session_id
    drop_table :self_test_sessions
  end
end
