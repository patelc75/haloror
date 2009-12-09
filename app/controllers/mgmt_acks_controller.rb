class MgmtAcksController < RestfulAuthController
  def create
    # 1. Create Ack, link with Cmd
    request = params[:management_ack_device]

    conds = []
    conds << "originator = 'server'"
    conds << "pending = true"
    conds << "pending_on_ack = true"
    conds << "attempts_no_ack > 0"    
    conds << "cmd_type = '#{request[:cmd_type]}'"
    conds << "device_id = #{request[:device_id]}"
        
    cmd = MgmtCmd.find(:first, :conditions => conds.join(' and '), :order => "id asc")
    
    if !cmd.nil? and !cmd.mgmt_ack  #in case an ack is delayed or a stray ack is sent
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
