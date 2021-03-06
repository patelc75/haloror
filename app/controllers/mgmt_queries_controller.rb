class MgmtQueriesController < RestfulAuthController
  # POST /mgmt_queries  
  def create
    #Create a GWOnlineAlert if in offline mode (reconnected_at == nil) 
    request = params[:management_query_device]
    
    query = MgmtQuery.new
    query.device_id = request[:device_id]
    query.timestamp_device = request[:timestamp]
    query.timestamp_server = Time.now
    query.poll_rate = request[:poll_rate]
    query.cycle_num = request[:cycle_num]
    query.save
    
    #trigger a gateway online alert (has to occur after mgmt_query is saved above)
    dlq = DeviceLatestQuery.find(request[:device_id])
    if(dlq and dlq.reconnected_at == nil)
      GatewayOnlineAlert.create(:device => Device.find(dlq.id))
      dlq.reconnected_at = Time.now
      dlq.save!
    end
    
    conds = []
    if(!query.cycle_num.blank?)
      if(query.cycle_num == 1)
        conds = []
        conds << "originator = 'server'"
        conds << "pending = true"  
        conds << "attempts_no_ack > 0" #so newly created mgmt_cmd is not immediately expired
        conds << "device_id = #{query.device_id}"
        
        pending_cmds_without_mgmt_response = MgmtCmd.find(:all, :conditions => conds.join(' and '))
        
        #close out pending commands from pervious query cycle and create new ones
        pending_cmds_without_mgmt_response.each do |pending|        
          pending.pending = false
          pending.save
          
          new_cmd = MgmtCmd.new
          new_cmd.pending_on_ack = true
          new_cmd.pending = true
          new_cmd.creator = pending.creator
          new_cmd.attempts_no_ack = 0;
          new_cmd.device_id = pending.device_id
          new_cmd.user_id = pending.user_id
          new_cmd.timestamp_initiated = pending.timestamp_initiated
          new_cmd.cmd_type = pending.cmd_type
          new_cmd.originator = pending.originator
          new_cmd.cmd_id = pending.cmd_id
          new_cmd.param1 = pending.param1
          new_cmd.param2 = pending.param2
          new_cmd.param3 = pending.param3
          new_cmd.param4 = pending.param4
          new_cmd.instantaneous = pending.instantaneous                                            
          new_cmd.save
        end        
      end
      conds = []
      conds << "pending_on_ack = true" #inside if statement for backward compatibility (if no query.cycle_num)
    end  
    
    conds << "originator = 'server'"
    conds << "pending = true"  #this is reset to false in mgmt_acks_controller.rb    
    conds << "device_id = #{query.device_id}"
    
    pending_on_ack_and_response = MgmtCmd.find(:first, :conditions => conds.join(' and '), :order => 'timestamp_initiated DESC')
    
    if(!pending_on_ack_and_response.nil?)
      if pending_on_ack_and_response.attempts_no_ack.nil?
        pending_on_ack_and_response.attempts_no_ack = 0
        pending_on_ack_and_response.save
      end
      if(pending_on_ack_and_response.attempts_no_ack < MGMT_CMD_ATTEMPTS_WITHOUT_ACK)
        send_command(pending_on_ack_and_response, query)
        pending_on_ack_and_response.attempts_no_ack += 1
        
        if pending_on_ack_and_response.attempts_no_ack >= MGMT_CMD_ATTEMPTS_WITHOUT_ACK
          pending_on_ack_and_response.pending_on_ack = false
        end
        
        pending_on_ack_and_response.save
        
        if pending_on_ack_and_response.cmd_type == "firmware_upgrade"
          render :layout => false, :partial => "management/command_firmware_upgrade", :locals => {:cmd => pending_on_ack_and_response, :more => @more}
        else        
          render :layout => false, :partial => "management/command", :locals => {:cmd => pending_on_ack_and_response, :more => @more}
        end
      else
        render :nothing => true #indicates query cycle is over    
      end
    else
      render :nothing => true #indicates query cycle is over
    end
  end
  
  def send_command(cmd, query)
    if cmd
      @more = nil
      if cmd.cmd_type == 'firmware_upgrade' && cmd.cmd_id
        @more = FirmwareUpgrade.find(cmd.cmd_id) 
        @more[:instantaneous] = cmd.instantaneous
      elsif cmd.cmd_type == 'mgmt_poll_rate' && cmd.param1
        @more = {'poll_rate' => cmd.param1,'instantaneous' => cmd.instantaneous }
      elsif cmd.cmd_type == 'dial_up_num' && cmd.param1 && cmd.param2 && cmd.param3
        @more = {'number' => cmd.param1,'username' => cmd.param2,'password' => cmd.param3,'instantaneous' => cmd.instantaneous }
      elsif cmd.cmd_type == 'dial_up_num_glob_prim' && (cmd.param1 or cmd.param2 or cmd.param3 or cmd.param4)
        cmd.cmd_type = 'dial_up_num'
        cmd.save
        @local_pri = DialUp.find_by_phone_number(cmd.param1)   
        @local_alt = DialUp.find_by_phone_number(cmd.param2)   
        @global_pri = DialUp.find_by_phone_number(cmd.param3)   
        @global_alt = DialUp.find_by_phone_number(cmd.param4)   
        
        @more = {'instantaneous' => cmd.instantaneous }
        @more = @more.merge({'number' => cmd.param1,'username' => @local_pri.username,'password' => @local_pri.password}) if @local_pri        
        @more = @more.merge({'alt_number' => cmd.param2,'alt_username' => @local_alt.username,'alt_password' => @local_alt.password}) if @local_alt
        @more = @more.merge({'global_prim_number' => cmd.param3,'global_prim_username' => @global_pri.username,'global_prim_password' => @global_pri.password}) if @global_pri
        @more = @more.merge({'global_alt_number' => cmd.param4,'global_alt_username' => @global_alt.username,'global_alt_password' => @global_alt.password}) if @global_alt
        
      elsif cmd.cmd_type == 'remote_access'
        @more = {'instantaneous' => cmd.instantaneous }
        # 
        #  Tue Feb  8 01:42:39 IST 2011, ramonrails
        #   * https://redmine.corp.halomonitor.com/issues/4043
        unless cmd.instantaneous
          @more[ 'start_time'] = (cmd.param1.blank? ? Time.now : cmd.param1)
          @more[ 'duration']   = cmd.param2
        end
      end
      
      query.mgmt_cmd_id = cmd.id
      query.save
      
      cmd.timestamp_sent = Time.now
      cmd.save
    end
  end
end