class MgmtCmdsController < RestfulAuthController
  # POST /mgmt_cmds
  skip_before_filter :authenticated?
  before_filter :authenticated?, :only => [:create]
  
  #this create method is called for both outbound and inbound (server or device originated)
  def create
    registration_device_id = '4294967295'
    
    # 1. Create mgmt_cmd
    request = params[:management_cmd_device]
    
    cmd = MgmtCmd.new
    cmd.cmd_type = request[:cmd_type]    
    cmd.timestamp_initiated = request[:timestamp]
    cmd.device_id = request[:device_id]

    
    if !params[:originator]
      cmd.originator = "device"
    else
      cmd.originator = params[:originator]
      
      if params[:originator] == 'server'
        cmd.pending = true
        cmd.pending_on_ack = true
        cmd.creator = current_user
      end
    end
    
    # for device_id, it is searched in the device table by serial num
    if cmd.cmd_type == 'device_registration' && request[:device_id] == registration_device_id  #create device
      unless device = Device.find_by_serial_number(request[:serial_num])
        device = Device.new
        device.serial_number = request[:serial_num]
        device.save
      end
      
      cmd.device_id = device.id
    end
    
    # link to user
    if request[:device_id] && request[:device_id] != registration_device_id
      if device = Device.find(request[:device_id])
        if cmd.cmd_type == 'user_registration'
          if(device.users.first)
            cmd.user_id = device.users.first.id
          else
            cmd.user_id = nil
          end
        end
      end
    end
    
    if(cmd.originator == "device")
      cmd.pending = false
    end
    
    cmd.save    
    
    # 3. Create mgmt_response
    response = MgmtResponse.new
    response.mgmt_cmds << cmd
    response.timestamp_server = Time.now
    response.save
    
    render :layout =>false, :partial => "management/response", :locals => {:response => response}
  end
end 
