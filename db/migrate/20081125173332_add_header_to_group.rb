class AddHeaderToGroup < ActiveRecord::Migration
  def self.up
    drop_table :call_center_steps_groups
    create_table :call_center_groups, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :heading, :string
      t.column :call_center_session_id, :integer
      t.column :updated_at, :timestamp_with_time_zone
      t.column :created_at, :timestamp_with_time_zone
    end
  end

  def self.down
    
  end
end
