class CreateGwAlarmButtons < ActiveRecord::Migration
  def self.up
    create_table :gw_alarm_buttons do |t|
	  t.column :id, :primary_key, :null => false 
      t.column :device_id, :integer
      t.column :user_id, :integer	  
      t.column :timestamp, :timestamp_with_time_zone	
      t.timestamps
    end
  end

  def self.down
    drop_table :gw_alarm_buttons
  end
end
