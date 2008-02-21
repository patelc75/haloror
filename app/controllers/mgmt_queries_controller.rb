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
    cmds = MgmtCmd.find(:all, :conditions => {:originator => 'server', :pending => true})
    
    # 3. Send cmds back to device
    cmds.each do |cmd|
      cmd.timestamp_sent = Time.now
      cmd.save
    end
    
    if cmds
      render :layout =>false, :partial => "management/commands", :locals => {:cmds => cmds}
    end
  end
end
