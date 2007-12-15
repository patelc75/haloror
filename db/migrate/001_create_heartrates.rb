class CreateHeartrates < ActiveRecord::Migration
  def self.up
    create_table :heartrates do |t|
	  t.column :id, :primary_key, :null => false 
	  t.column :user_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :heartrate, :integer, :limit => 1, :null=> false #will use smallint because of plug-in
    end
  end

  def self.down
    drop_table :heartrates
  end
end