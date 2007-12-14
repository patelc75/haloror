class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
	  t.column :id, :primary_key, :null => false 
	  t.column :user_id, :integer
	  t.column :kind, :string
	  t.column :kind_id, :integer		
      t.column :timestamp, :timestamp_with_time_zone	  
    end
  end

  def self.down
    drop_table :events
  end
end
