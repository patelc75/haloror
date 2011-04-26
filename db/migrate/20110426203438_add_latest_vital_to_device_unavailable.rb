class AddLatestVitalToDeviceUnavailable < ActiveRecord::Migration
  def self.up
    #add_column :device_unavailable_alerts, :latest_vital_at, :timestamp_with_time_zone
    #add_column :device_available_alerts, :latest_vital_at, :timestamp_with_time_zone    

    #add_column :device_unavailable_alerts, :is_fastened_at, :timestamp_with_time_zone
    #add_column :device_available_alerts, :is_fastened_at, :timestamp_with_time_zone    

    #add_column :device_unavailable_alerts, :is_fastened, :integer
    #add_column :device_available_alerts, :is_fastened, :integer    

    #add_column :device_unavailable_alerts, :access_mode, :string
    #add_column :device_available_alerts, :access_mode, :string    
  end

  def self.down        
    #remove_column :device_unavailable_alerts, :latest_vital_at
    #remove_column :device_available_alerts, :latest_vital_at  
    #remove_column :device_unavailable_alerts, :is_fastened_at
    #remove_column :device_available_alerts, :is_fastened_at  
    #remove_column :device_unavailable_alerts, :is_fastened
    #remove_column :device_available_alerts, :is_fastened
    #remove_column :device_unavailable_alerts, :access_mode
    #remove_column :device_available_alerts, :access_mode
  end
end
