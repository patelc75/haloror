class MgmtCmdsController < ApplicationController
  # POST /mgmt_cmds
  def create
    # 1. Create mgmt_cmd
    request = params[:management_cmd_device]
    
    cmd = MgmtCmd.new
    cmd.device_id = request[:device_id]
    cmd.timestamp_sent = request[:timestamp]
    cmd.cmd_type = request[:cmd_type]
    
    if !params[:originator]
      cmd.originator = "device"
    else
      cmd.originator = params[:originator]
    end
    
    cmd.save
    
    # 2. Create mgmt_response
    response = MgmtResponse.new
    response.mgmt_cmd_id = cmd.id
    response.timestamp_server = Time.now
    response.save
    
    render :layout =>false, :partial => "management/response", :locals => {:response => response}
  end
end
