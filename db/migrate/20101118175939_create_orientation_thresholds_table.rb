class CreateOrientationThresholdsTable < ActiveRecord::Migration
  def self.up
    create_table :orientation_thresholds do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer
      t.column :begin_time, :timestamp_with_time_zone
      t.column :end_time, :timestamp_with_time_zone
      t.column :min_angle, :integer 
      t.column :max_angle, :integer       
      t.column :created_at, :timestamp_with_time_zone
    end
  end

  def self.down
    drop_table :lost_data_skin_temps
  end
end
                                              
