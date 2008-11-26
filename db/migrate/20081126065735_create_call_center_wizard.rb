class CreateCallCenterWizard < ActiveRecord::Migration
  def self.up
    create_table :call_center_wizards, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :event_id, :integer
      t.column :operator_id, :integer
      t.column :user_id, :integer
      t.column :call_center_session_id, :integer
      t.column :updated_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
    end
    drop_table :call_center_groups
  end

  def self.down
  end
end
