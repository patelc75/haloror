class CreateStrapRemoveds < ActiveRecord::Migration
  def self.up
    create_table :strap_removeds do |t|
      t.column :id, :primary_key, :null => false 
      t.column :device_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
    end
  end

  def self.down
    drop_table :strap_removeds
  end
end
