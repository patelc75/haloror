class MgmtAcksController < RestfulAuthController
  def create
    # 1. Create Ack, link with Cmd
    request = params[:management_ack_device]

    conds = []
    conds << "originator = 'server'"
    conds << "pending = true"
    conds << "pending_on_ack = true"
    conds << "cmd_type = '#{request[:cmd_type]}'"
    conds << "device_id = #{request[:device_id]}"
        
    cmd = MgmtCmd.find(:first, :conditions => conds.join(' and '), :order => "id asc")
    
    unless cmd.mgmt_ack
      ack = MgmtAck.new
      ack.mgmt_cmd_id = cmd.id
      ack.timestamp_device = request[:timestamp]
      ack.timestamp_server = Time.now
      ack.save
      
      cmd.pending_on_ack = false
      cmd.save
    end
    
    render :nothing => true
  end
end
