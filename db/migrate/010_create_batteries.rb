class CreateBatteries < ActiveRecord::Migration
  def self.up
    create_table :batteries do |t|
	  t.column :id, :primary_key, :null => false 
	  t.column :user_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :percentage, :integer, :limit => 1, :null=> false
	 
	  #remaining battery life 0 to 1 year range
	  t.column :time_remaining, :integer, :limit => 4, :null=> false 
    end
  end

  def self.down
    drop_table :batteries
  end
end
