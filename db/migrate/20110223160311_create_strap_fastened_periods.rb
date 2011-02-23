class CreateStrapFastenedPeriods < ActiveRecord::Migration
  def self.up   
    create_table :strap_fastened_periods do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer
      t.column :begin_time, :timestamp_with_time_zone
      t.column :end_time, :timestamp_with_time_zone   
      t.column :duration, :interval    
    end    
  end

  def self.down
  end
end
