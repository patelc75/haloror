class MgmtQueriesController < ApplicationController
  # POST /mgmt_queries
  def create
    # 1. Create mgmt_query
    request = params[:management_query_device]
    
    query = MgmtQuery.new
    query.device_id = request[:device_id]
    query.timestamp_device = request[:timestamp]
    query.timestamp_server = Time.now
    query.poll_rate = request[:poll_rate]
    query.save
    
    # 2. Look for mgmt_cmds where originator = server and pending = true
    cmds = MgmtCmd.find(:all, :conditions => {:originator => 'server', :pending => true, :device_id => query.device_id})
    
    cmds.each do |cmd|
      similar = MgmtCmd.find(:all, :conditions => {:timestamp_initiated => cmd.timestamp_initiated})
    
      if similar.length == 5
        cmd.pending = false
        cmd.save
      else
        if cmd.mgmt_ack || !cmd.timestamp_sent
          send_command(cmd,query)
          break
        else
          cmd.pending = false
          cmd.save

          new_cmd = MgmtCmd.new
          new_cmd.device_id = cmd.device_id
          new_cmd.user_id = cmd.user_id
          new_cmd.timestamp_initiated = cmd.timestamp_initiated
          new_cmd.cmd_type = cmd.cmd_type
          new_cmd.originator = cmd.originator
          new_cmd.cmd_id = cmd.cmd_id
          new_cmd.save
      
          send_command(new_cmd, query)
          break
        end
      end
    end
    
    if @cmd
      render :layout => false, :partial => "management/commands", :locals => {:cmd => @cmd, :more => @more}
    else
      render :nothing => true
    end
  end
  
  def send_command(cmd, query)
    if cmd
      # 3. Get more info
      @more = nil
      if cmd.cmd_type == 'firmware_upgrade' && cmd.cmd_id
        @more = FirmwareUpgrade.find(cmd.cmd_id)
      end
      
      # 4. Link cmd to query

      query.mgmt_cmd_id = cmd.id
      query.save

      # 5. Send cmd back to device
      cmd.timestamp_sent = Time.now
      cmd.save
      
      @cmd = cmd
    end
  end
end
