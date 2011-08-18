class AddDeviceIdtoOscope < ActiveRecord::Migration
  def self.up
    add_column :oscope_start_msgs, :device_id, :integer
    add_column :oscope_stop_msgs,  :device_id, :integer    
  end

  def self.down
    remove_column :oscope_start_msgs, :device_id
    remove_column :oscope_stop_msgs,  :device_id    
  end
end
