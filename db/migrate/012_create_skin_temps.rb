class CreateSkinTemps < ActiveRecord::Migration
  def self.up
    create_table :skin_temps do |t|
	  t.column :id, :primary_key, :null => false 
	  t.column :user_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :skin_temp, :integer, :limit => 2, :null=> false		
    end
  end

  def self.down
    drop_table :skin_temps
  end
end
