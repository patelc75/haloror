class MgmtAcksController < ApplicationController
  def create
    # 1. Create Ack, link with Cmd
    request = params[:management_ack_device]
        
    cmd = MgmtCmd.find(:first, :conditions => {:cmd_type => request[:cmd_type], :device_id => request[:device_id]}, :order => "id asc")
    
    unless cmd.mgmt_ack
      ack = MgmtAck.new
      ack.mgmt_cmd_id = cmd.id
      ack.timestamp_device = request[:timestamp]
      ack.timestamp_server = Time.now
      ack.save
    end
    
    render :nothing => true
  end
end
