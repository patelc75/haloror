class MgmtResponsesController < ApplicationController
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
    end
    
    render :nothing => true
  end
end
