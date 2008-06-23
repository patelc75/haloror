class MgmtResponsesController < RestfulAuthController
  @@responses_cmds = {"info" => ["firmware_upgrade", "info"], "reset" => ["reset"]}
  
  def conditions_from_hash(response)
    conds = []
    @@responses_cmds["#{response}"].each do |cmd|
      conds << "cmd_type = '#{cmd}'"
    end
    
    conds.join(' or ')
  end
  
  def create
    # 1. Create Response, link with Cmd
    request = params[:management_response_device]
    conditions = conditions_from_hash(request[:cmd_type])    
    cmds = MgmtCmd.find(:all, :conditions => "(#{conditions}) and device_id = #{request[:device_id]} and timestamp_sent is not null and pending = true", :order => "id asc")
    if !cmds.blank?
      response = MgmtResponse.new
      #response.mgmt_cmd_id = cmd.id
      response.timestamp_device = request[:timestamp]
      response.timestamp_server = Time.now
      response.save
           
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
      
      cmds.each do |cmd|
        #unless cmd.mgmt_response
        response.mgmt_cmds << cmd
        cmd.pending = false
        cmd.save
        #end
      end
    else
      # create null command (cmd_type => no command)
      cmd = MgmtCmd.new
      cmd.device_id = request[:device_id]
      cmd.cmd_type = 'no_command'
      cmd.originator = "server"
      cmd.pending = false
      cmd.save
      
      # link null response to command
      response = MgmtResponse.new
      response.timestamp_device = request[:timestamp]
      response.timestamp_server = Time.now
      response.mgmt_cmds << cmd
      response.save
    end
    
    render :nothing => true
  end
end
