class ManagementController < ApplicationController
  
  before_filter :authenticate_admin?
  
  def mgmt_cmds
    @type = 'mgmt_cmds'
    @bad_cmds = []
    @cmds = []
    set_times
    if device = get_device
      @cmds = get_mgmt_cmds_stream(device)
      @bad_cmds = get_bad_mgmt_cmds_stream(device)
    end
    
    render :action => 'index'
  end
    
  def delete_cmd
    MgmtCmd.delete(params[:id])
    render :nothing => true
  end
  def delete_ack
    MgmtAck.delete(params[:id])
    render :nothing => true
  end
  
  def index
    unless @type = session[:type]
      @type = 'stream'
    end
    
    @chatter = Array.new
    set_times
    if device = get_device
      @chatter = get_queries(@type, device)
    end
  end
  
  def stream
    @type = 'stream'
    set_times
    if device = get_device
      @chatter = get_queries("stream", device)
    end
    
    render :action => 'index'
  end
  
  def group
    @type = 'group'
    set_times
    if device = get_device
      @chatter = get_queries("group", device)
    end
    
    render :action => 'index'
  end

  def firmware_upgrade
    if params[:keyID].to_i != 0
      fw = FirmwareUpgrade.find(params[:keyID])
      fw.update_attribute(params[:field].to_sym, params[:value])
      fw.save
      render :json => '{success: true}'
    else
      fw = FirmwareUpgrade.new()
      fw.version = 'New Version'
      fw.filename = 'filename'
      ftp = Ftp.find(:first)
      fw.ftp_id = ftp.id if ftp
      fw.description = 'description'
      fw.date_added = Date.today
      fw.save
      render :json => "{success:true, newID: #{fw.id}}", :layout => false
    end  
  end
  
  def firmware_upgrade_delete
    if params[:ids]
      RAILS_DEFAULT_LOGGER.warn(params[:ids])
      str = params[:ids].chop
      RAILS_DEFAULT_LOGGER.warn(str)
      str = str[1, str.length-1]
      RAILS_DEFAULT_LOGGER.warn(str)
      str_array = str.split(',')
      str_array.each do |s|
        FirmwareUpgrade.delete(s)
      end
      fus = FirmwareUpgrade.find(:all, :include => 'ftp') 
      fus_json = "{ 'rows': ["
      count = 0
      fus.each do |fu|
        fus_json = fus_json + fu.to_json()
        count = count + 1
        unless count == fus.length
          fus_json = "#{fus_json}, "
        end
      end
      fus_json = "#{fus_json} ] }"
      render :json => fus_json, :layout => false
    end
  end
  
  def create_many
  	
    @success = true
    #@message = "Command created"
    @message = "Command created by #{current_user.id} #{current_user.name}"
    @pending_cmds = []
    
    request = params[:management_cmd_device] #from the issue commands form
    
    if request[:cmd_type] == nil
      @success = false
      @message = 'Please select a command type.'
    else
      if !request[:ids].empty?
        cmd = {}
        cmd[:cmd_type] = request[:cmd_type]

        #this is here if there's more to cmd than just the basics (i.e. firmware_upgrate, mgmt_poll_rate)
        cmd[:cmd_id] = params[request[:cmd_type].to_sym]  
        
        cmd[:timestamp_initiated] = Time.now
        cmd[:originator] = 'server'
        cmd[:attempts_no_ack] = 0
        cmd[:pending_on_ack] = true
        cmd[:created_by] = current_user.id if current_user
        
        #command specific parameter (such as <poll_rate> for the mgmt_poll_rate cmd)
        cmd[:param1] = request[:param1] if !request[:param1].blank? and request[:cmd_type] == 'mgmt_poll_rate'
        cmd[:param1] = request[:param2] if !request[:param2].blank? and request[:cmd_type] == 'dial_up_num'
        cmd[:param2] = request[:param3] if !request[:param3].blank? and request[:cmd_type] == 'dial_up_num'
        cmd[:param3] = request[:param4] if !request[:param4].blank? and request[:cmd_type] == 'dial_up_num'
        
        if /-/.match(request[:ids])     
          create_cmds_for_range_of_devices(request[:ids], cmd)
        elsif /,/.match(request[:ids]) 
          create_cmds_for_devices_separated_by_commas(request[:ids], cmd)
        elsif                     
          create_cmd_for_single_id(request[:ids], cmd)
        end
      else
        @success = false
        @message = 'Please provide device ids.'        
      end
    end
    render :layout => false
  end
  
  def issue
    @firmware_upgrades = FirmwareUpgrade.find(:all, :order => 'id desc')
    @ftps = Ftp.find(:all, :order => 'id desc')
  end
  
  def new_firmware_upgrade
    @firmware_upgrade = FirmwareUpgrade.new
    @ftps = Ftp.find(:all)
  end
  
  def edit_firmware_upgrade
    @firmware_upgrade = FirmwareUpgrade.find(params[:id])
    @ftps = Ftp.find(:all)
  end
  
  def save_firmware_upgrade
    @firmware_upgrade = FirmwareUpgrade.new(params[:firmware_upgrade])
    @ftp = Ftp.find(params[:ftp_id])
    @firmware_upgrade.ftp = @ftp
    @firmware_upgrade.save!
    redirect_to :action => 'issue'
  end
  
  def update_firmware_upgrade
    @firmware_upgrade = FirmwareUpgrade.find(params[:firmware_upgrade][:id])
    @firmware_upgrade.update_attributes(params[:firmware_upgrade])
    @ftp = Ftp.find(params[:ftp_id])
    @firmware_upgrade.ftp = @ftp
    @firmware_upgrade.save!
    redirect_to :action => 'issue'
  end
  
  def new_ftp
    @ftp = Ftp.new
  end
  
  def edit_ftp
    @ftp = Ftp.find(params[:id])
  end
  
  def save_ftp
    @ftp = Ftp.new(params[:ftp])
    @ftp.save!
    redirect_to :action => 'issue'
  end
  
  def update_ftp
    @ftp = Ftp.find(params[:ftp][:id])
    @ftp.update_attributes(params[:ftp])
    @ftp.save!
    redirect_to :action => 'issue'
  end
  protected
  
  def get_device
    device = nil
    if params[:device_id2].blank?
      if params[:device] && params[:device][:id]
        device = Device.find(params[:device][:id])
      end
    else
      if params[:device_id2]
        device = Device.find(params[:device_id2])
      end
    end
    unless device
      device = current_user.devices.first
    end
    @device = device
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
    
    # device.mgmt_cmds.each do |cmd|
    #     cmd[:timestamp] = cmd[:timestamp_initiated]
    #     cmd[:type] = 'cmd'
    #     chatter << cmd
    # end
    queries = device.mgmt_queries.find(:all, :conditions => "timestamp_device > '#{@begin_time}' AND timestamp_device < '#{@end_time}'")
    queries.each do |query|
      next unless query[:timestamp_device]
      
      query[:timestamp] = query[:timestamp_device]
      query[:type] = 'query'
      chatter << query
    end
    
    chatter
    
    # get command
    # get query
    # get ack
    # get response
  end
  
  def query_stream(device)
    chatter = Array.new
    
    # get the queries and all associated cmds, acks, and responses
    device.mgmt_queries.find(:all, :conditions => "timestamp_server > '#{@begin_time}' AND timestamp_server < '#{@end_time}'").each do |query|
      next unless query[:timestamp_server]
      
      query[:timestamp] = query[:timestamp_server]
      query[:type] = 'query'
      chatter << query
      
      if cmd = query.mgmt_cmd
        next unless cmd[:timestamp_sent]
        
        cmd[:timestamp] = cmd[:timestamp_sent]
        cmd[:query_group] = true
        cmd[:type] = 'cmd'
        chatter << cmd
        
        if ack = cmd.mgmt_ack
          next unless ack[:timestamp_server]
          
          ack[:timestamp] = ack[:timestamp_server]
          ack[:type] = 'ack'
          chatter << ack
        end
        
        if response = cmd.mgmt_response
          next unless response[:timestamp_server]
          
          response[:timestamp] = response[:timestamp_server]
          response[:type] = 'response'
          chatter << response
        end
      end
    end
    
    #get all cmds not associated with a mgmt_query
    device.mgmt_cmds.find(:all,
                          :conditions => "id NOT IN (select mgmt_cmd_id from mgmt_queries) AND timestamp_initiated > '#{@begin_time}' AND timestamp_initiated < '#{@end_time}'").each do |cmd|
      next unless cmd[:timestamp_sent]
      
      cmd[:timestamp] = cmd[:timestamp_sent]
      cmd[:query_group] = false
      cmd[:type] = 'cmd'
      chatter << cmd
      
      if ack = cmd.mgmt_ack
        next unless ack[:timestamp_server]
        ack[:timestamp] = ack[:timestamp_server]
        ack[:type] = 'ack'
        chatter << ack
      end
      
      if response = cmd.mgmt_response
        next unless response[:timestamp_server]
        
        response[:timestamp] = response[:timestamp_server]
        response[:type] = 'response'
        chatter << response
      end
      
    end
    
    # get pending commands
    device.mgmt_cmds.find(:all, :conditions => "timestamp_initiated > '#{@begin_time}' AND timestamp_initiated < '#{@end_time}'").each do |cmd|
      unless cmd.mgmt_ack
        next unless cmd[:timestamp_initiated]
        
        cmd[:timestamp] = cmd[:timestamp_initiated]
        cmd[:query_group] = false
        cmd[:type] = 'cmd'
        chatter << cmd
      end
    end
    
    chatter
  end
  
  def set_times
    @query = LostData.new(params[:query])
    @begin_time = Time.now
    @end_time = @begin_time
    if !params[:begin_time].blank?
      @begin_time = params[:begin_time]
    end
    if !params[:end_time].blank?
      @end_time = params[:end_time]
    end
  end
  
  def delete
    MgmtCmd.delete(params[:id])
    render :nothing => true
  end

  private
 
  def create_cmds_for_range_of_devices(ids, cmd)
    arr = ids.split('-')
    
    min = arr[0].to_i
    max = arr[1].to_i
    
    if min && max
      count = min
      while count <= max
        cmd[:device_id] = count
        
        @pending_cmds += MgmtCmd.pending_server_cmds_by_type(count, cmd[:cmd_type])
        if @pending_cmds.length == 0
          MgmtCmd.create(cmd)
        end
        
        count+=1
      end
    else
      @success = false
      @message = 'Please provide a min and max for the range of device ids.'
    end
  end
  
  def create_cmds_for_devices_separated_by_commas(ids, cmd)
    ids.split(',').each do |id|          
      if id
        cmd[:device_id] = id
        
        @pending_cmds += MgmtCmd.pending_server_cmds_by_type(id, cmd[:cmd_type])
        if @pending_cmds.length == 0
          MgmtCmd.create(cmd)
        end
      end
    end
  end
  
  def create_cmd_for_single_id(id, cmd)
    cmd[:device_id] = id
    
    @pending_cmds = MgmtCmd.pending_server_cmds_by_type(id, cmd[:cmd_type])
    if @pending_cmds.length == 0
      MgmtCmd.create(cmd)
    end
  end
  
  def get_mgmt_cmds_stream(device)
    cmds = device.mgmt_cmds.find(:all, 
                          :order => 'timestamp_initiated desc',
                          :include => :mgmt_response, 
                          :conditions => "timestamp_initiated > '#{@begin_time}' AND timestamp_initiated < '#{@end_time}'")
    return cmds
  end
  
  def get_bad_mgmt_cmds_stream(device)
    #Bad timestaamps*
    #> Time.now and < 2.years
    bad_cmds = device.mgmt_cmds.find(:all, 
                                      :order => 'timestamp_initiated desc', 
                                      :include => :mgmt_response, 
                                      :conditions => "timestamp_initiated > '#{Time.now.to_s}' OR timestamp_initiated < '#{2.years.ago.to_s}'")
    return bad_cmds
  end
end
