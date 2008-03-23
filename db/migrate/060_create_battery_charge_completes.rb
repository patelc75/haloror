class CreateBatteryChargeCompletes < ActiveRecord::Migration
  def self.up
    create_table :battery_charge_completes do |t|
      t.column :id, :primary_key, :null => false 
      t.column :device_id, :integer
      t.column :timestamp, :timestamp_with_time_zone      
      t.column :percentage, :integer, :limit => 1, :null=> false
      t.column :time_remaining, :integer, :limit => 4, :null=> false 
    end
  end

  def self.down
    drop_table :battery_charge_completes
  end
end
