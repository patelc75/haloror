class MgmtResponsesController < RestfulAuthController
  @@responses_cmds = {"info" => ["firmware_upgrade", "info"], "reset" => ["reset"]}
  
  def conditions_from_hash(response)
    conds = []
    @@responses_cmds["#{response}"].each do |cmd|
      conds << "cmd_type = '#{cmd}'"
    end
    if conds.empty?
      conds << "cmd_type = '#{response}'"
    else
      conds.join(' or ')
    end
    

  end
  
  def create
    # 1. Create Response, link with Cmd
    request = params[:management_response_device]
    
    conds = []
    conds << "(" + conditions_from_hash(request[:cmd_type]) + ")"
    conds << "device_id = #{request[:device_id]}"
    conds << "timestamp_sent is not null"
    conds << "pending = true"
    
    cmds = MgmtCmd.find(:all, :conditions => conds.join(' and '), :order => "id asc")
    
    response = MgmtResponse.new 
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
    
    if !cmds.blank? 
      cmds.each do |cmd|
        if !request[:info].blank? && cmd.cmd_type == 'firmware_upgrade' && cmd.cmd_id
          firmware_upgrade = FirmwareUpgrade.find(cmd.cmd_id)
          if firmware_upgrade && firmware_upgrade.version != request[:info][:software_version]
            cmd.pending = true
          end
        end
        if !cmd.pending.blank?
          cmd.pending = false
        end
        response.mgmt_cmds << cmd
        cmd.save
      end
    else
      # create null command (cmd_type => no command)
      cmd = MgmtCmd.new
      cmd.device_id = request[:device_id]
      cmd.cmd_type = request[:cmd_type]
      cmd.originator = "neither"
      cmd.pending = false
      cmd.pending_on_ack = false
      cmd.timestamp_initiated = request[:timestamp]
      cmd.save
      
      # link null response to command
      response.mgmt_cmds << cmd
    end
    
    render :nothing => true
  end
end
