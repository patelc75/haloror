class MgmtResponsesController < RestfulAuthController
  def create
    # 1. Create Response, link with Cmd
    request = params[:management_response_device]
        
    if cmd = MgmtCmd.find(:first, :conditions => {:cmd_type => request[:cmd_type], :device_id => request[:device_id]}, :order => "id asc")
      unless cmd.mgmt_response
        response = MgmtResponse.new
        response.mgmt_cmd_id = cmd.id
        response.timestamp_device = request[:timestamp]
        response.timestamp_server = Time.now
        response.save
      
        cmd.pending = false
        cmd.save
      
        if i = request[:info]
          info = DeviceInfo.new
          info.device_id = request[:device_id]
          info.mgmt_response_id = response.id
          info.user_id = i[:user_id]
          info.serial_number = i[:serial_num]
          info.mac_address = i[:mac_address]
          info.vendor = i[:vendor]
          info.model = i[:model]
          info.hardware_version = i[:hardware_version]
          info.software_version = i[:software_version]        
          info.save
        end      
      end
    else
      # create null command (cmd_type => no command)
      cmd = MgmtCmd.new
      cmd.device_id = request[:device_id]
      cmd.cmd_type = 'no_command'
      cmd.save
      
      # link null response to command
      response = MgmtResponse.new
      response.mgmt_cmd_id = cmd.id
    end
    
    render :nothing => true
  end
end
