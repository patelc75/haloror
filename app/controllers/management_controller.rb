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
  
  def roles
    @roles = ['administrator', 'operator', 'caregiver']
    
    @users = {''=>''}
    
    User.find(:all).each do |user|
      if user
        @users[user.login] = user.id
      end
    end
  end
  
  def assign_role
    role = params[:role]
    
    unless role[:user].empty?
      unless role[:of].empty?
        User.find(role[:user]).has_role role[:name], User.find(role[:of])
      else
        User.find(role[:user]).has_role role[:name]
      end
      
      @success = true
      @message = "Role Assigned"
    else
      @success = false
      @message = "Choose a user"
    end   
    
    render :layout => false 
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
end
