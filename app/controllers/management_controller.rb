class ManagementController < ApplicationController
  
  #before_filter :authenticate_admin, :only => 'index'
  before_filter :authenticate_admin
  
  def index
    unless @type = session[:type]
      @type = 'stream'
    end
    
    @chatter = Array.new
    
    if device = get_device
      @chatter = get_queries(@type, device)
    end
  end
  
  def stream    
    if device = get_device
      render :partial => 'chatter_stream', :locals => {:chatter => get_queries("stream", device)}
    end
  end
  
  def group    
    if device = get_device
      render :partial => 'chatter_group', :locals => {:chatter => get_queries("group", device)}
    end
  end
  
  protected
  
  def get_device
    unless params[:device_id] && device = Device.find(params[:device_id])
      device = current_user.devices.first
    end
    
    device
  rescue ActiveRecord::RecordNotFound
    render :partial => 'device_not_found'
    nil
  end
  
  def get_queries(type, device)
    session[:type] = type
    
    chatter = query_stream(device) if type == 'stream'
    chatter = query_group(device) if type == 'group'
    
    chatter
  end
  
  def query_group(device)
    chatter = Array.new
    
    device.mgmt_cmds.each do |cmd|
        cmd[:timestamp] = cmd[:timestamp_initiated]
        cmd[:type] = 'cmd'
        chatter << cmd
    end
    
    chatter
    
    # get command
      # get query
      # get ack
      # get response
  end
  
  def query_stream(device)
    chatter = Array.new
    
    # get query groups
    
    device.mgmt_queries.each do |query|
      query[:timestamp] = query[:timestamp_server]
      query[:type] = 'query'
      chatter << query
    
      if cmd = query.mgmt_cmd
        cmd[:timestamp] = cmd[:timestamp_sent]
        cmd[:query_group] = true
        cmd[:type] = 'cmd'
        chatter << cmd
      
        if ack = cmd.mgmt_ack
          ack[:timestamp] = ack[:timestamp_server]
          ack[:type] = 'ack'
          chatter << ack
        end
      
        if response = cmd.mgmt_response
          response[:timestamp] = response[:timestamp_server]
          response[:type] = 'response'
          chatter << response
        end
      end
    end
    
    # get pending commands
    
    device.mgmt_cmds.each do |cmd|
      unless cmd.mgmt_ack
        cmd[:timestamp] = cmd[:timestamp_initiated]
        cmd[:query_group] = false
        cmd[:type] = 'cmd'
        chatter << cmd
      end
    end
    
    chatter
  end
  
  def auth
    current_user.has_role 'administrator'
    
    render :nothing => true
  end
end
