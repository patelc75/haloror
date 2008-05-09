class CreateSteps < ActiveRecord::Migration
  def self.up
    create_table :steps do |t|
      t.column :id, :primary_key, :null => false 
      t.column :user_id, :integer
      t.column :begin_timestamp, :timestamp_with_time_zone
      t.column :end_timestamp, :timestamp_with_time_zone	  
      t.column :steps, :integer, :limit => 1, :null=> false #will use smallint because of plug-in
    end
  end

  def self.down
    drop_table :steps
  end
end