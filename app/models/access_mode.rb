class AccessMode < DeviceAlert
  set_table_name "access_modes"

  belongs_to :device
  
  def to_s
    "Gateway now in #{mode} mode"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
  
  #so that chest straps are also included in the access_mode_status table for DeviceUnavailable alert to work
  def after_save
  	device.users.each do |u|  #all users on the GW
      u.devices.each do |d|   #all devices (including CSs) for the user
  	    if d.access_mode_status.nil?
      	  AccessModeStatus.create(:device_id => d.id, :mode => mode)
  	    else
  	      d.access_mode_status.mode = mode
  	      d.access_mode_status.save
  	    end
      end  		
  	end
  end
end