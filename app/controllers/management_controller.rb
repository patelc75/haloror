class ManagementController < ApplicationController
  
  #before_filter :authenticate_admin, :only => 'index'
  before_filter :authenticate_admin
  
  def index
    if params[:device_id] && device = Device.find(params[:device_id])
      device_queries(device)
      
      render :partial => 'chatter', :locals => {:chatter => @chatter}
    else
      device_queries(current_user.devices.first)
    end
  rescue ActiveRecord::RecordNotFound
    render :partial => 'device_not_found'
  end
  
  def device_queries(device)
    @chatter = Array.new
    
    # get query groups
    
    device.mgmt_queries.each do |query|
      query[:timestamp] = query[:timestamp_server]
      query[:type] = 'query'
      @chatter << query
    
      if cmd = query.mgmt_cmd
        cmd[:timestamp] = cmd[:timestamp_sent]
        cmd[:query_group] = true
        cmd[:type] = 'cmd'
        @chatter << cmd
      
        if ack = cmd.mgmt_ack
          ack[:timestamp] = ack[:timestamp_server]
          ack[:type] = 'ack'
          @chatter << ack
        end
      
        if response = cmd.mgmt_response
          response[:timestamp] = response[:timestamp_server]
          response[:type] = 'response'
          @chatter << response
        end
      end
    end
    
    # get pending commands
    
    device.mgmt_cmds.each do |cmd|
      unless cmd.mgmt_ack
        cmd[:timestamp] = cmd[:timestamp_initiated]
        cmd[:query_group] = false
        cmd[:type] = 'cmd'
        @chatter << cmd
      end
    end
  end
  
  def issue
    
  end
  
  def auth
    current_user.has_role 'administrator'
    
    render :nothing => true
  end
end
