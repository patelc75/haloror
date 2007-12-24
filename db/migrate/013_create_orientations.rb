class CreateOrientations < ActiveRecord::Migration
  def self.up
    create_table :orientations do |t|
	  t.column :id, :primary_key, :null => false 
	  t.column :user_id, :integer
	  t.column :timestamp, :timestamp_with_time_zone
	  t.column :orientation, :boolean
    end
  end

  def self.down
    drop_table :orientations
  end
end