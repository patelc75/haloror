class CreateStrapFasteneds < ActiveRecord::Migration
  def self.up
    create_table :strap_fasteneds do |t|
      t.column :id, :primary_key, :null => false 
      t.column :device_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
    end
  end

  def self.down
    drop_table :strap_fasteneds
  end
end
