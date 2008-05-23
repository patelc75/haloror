class CreateHaloDebugMsgs < ActiveRecord::Migration
  def self.up  
    create_table :halo_debug_msgs do |t|
      t.column :id, :primary_key, :null => false 
      t.column :source_mote_id, :integer
      t.column :timestamp, :timestamp_with_time_zone
      t.column :dbg_type, :integer
      t.column :param1, :integer
      t.column :param2, :integer
      t.column :param3, :integer
      t.column :param4, :integer
      t.column :param5, :integer
      t.column :param6, :integer
      t.column :param7, :integer
      t.column :param8, :integer
    end
  end

  def self.down
    drop_table :halo_debug_msgs
  end
end
