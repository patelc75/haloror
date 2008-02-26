class MgmtCmdsController < ApplicationController
  # POST /mgmt_cmds
  def create
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
    end
    
    # Call correct method in device model (if applicable)
    
    if cmd.cmd_type == 'device_registration'  #create device
      unless device = Device.find_by_serial_number(request[:serial_num])
        device = Device.new
        device.serial_number = request[:serial_num]
        device.save
      end
      
      cmd.device_id = device.id
    end
    
    # link to user
    if request[:device_id]
      if device = Device.find(request[:device_id])
        if cmd.cmd_type == 'user_registration'
          user_id = device.register_user 
          cmd.user_id = user_id
        else
          cmd.user_id = device.user.id
        end
      end
    end
    
    cmd.save
    
    
    
    # 3. Create mgmt_response
    response = MgmtResponse.new
    response.mgmt_cmd_id = cmd.id
    response.timestamp_server = Time.now
    response.save
    
    render :layout =>false, :partial => "management/response", :locals => {:response => response}
  end
end
