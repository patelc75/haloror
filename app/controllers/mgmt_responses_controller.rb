class MgmtResponsesController < RestfulAuthController
  def create
    # 1. Create Response, link with Cmd
    request = params[:management_response_device]
        
    cmd = MgmtCmd.find(:first, :conditions => {:cmd_type => request[:cmd_type], :device_id => request[:device_id]}, :order => "id asc")
    
    unless cmd.mgmt_response
      response = MgmtResponse.new
      response.mgmt_cmd_id = cmd.id
      response.timestamp_device = request[:timestamp]
      response.timestamp_server = Time.now
      response.save
      
      cmd.pending = false
      cmd.save
      
      if request[:info]
        info = DeviceInfo.new
      end
      
      # <user_id>UID</user_id> 
      #       <serial_num>sn</serial_num> 
      #       <mac_address>MAC</mac_address> 
      #       <vendor>vendorString</vendor> 
      #       <model>modelString</model> 
      #       <hardware_version>hdwVersion</hardware_version> 
      #       <software_version>swVersion</software_version> 
      
    end
    
    render :nothing => true
  end
end
