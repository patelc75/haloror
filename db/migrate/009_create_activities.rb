class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
	  t.column :user_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :activity, :integer, :limit => 4, :null=> false 
    end
  end

  def self.down
    drop_table :activities
  end
end