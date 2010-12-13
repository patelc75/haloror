# Wed Oct  6 23:58:40 IST 2010
#   "parse_integer_ranges" method was not recognized during deployment on sdev
#   this is a quick fix. just smoke tested
require "#{RAILS_ROOT}/config/initializers/string_extensions"

class ManagementController < ApplicationController
  
  before_filter :authenticate_admin?, :except => 'issue'
  before_filter :authenticate_admin_installer?, :only => 'issue'
  
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

        #this is here if there's more to cmd than just the basics (i.e. firmware_upgrade, mgmt_poll_rate)
        cmd[:cmd_id] = params[request[:cmd_type].to_sym]  
        
        cmd[:timestamp_initiated] = Time.now
        cmd[:originator] = 'server'
        cmd[:attempts_no_ack] = 0
        cmd[:pending_on_ack] = true
        cmd[:created_by] = current_user.id if current_user
        cmd[:instantaneous] = request[:instantaneous] == "1" ? true : false

        #command specific parameter (such as <poll_rate> for the mgmt_poll_rate cmd)
        cmd[:param1] = request[:param1] if !request[:param1].blank? and request[:cmd_type] == 'mgmt_poll_rate'
        cmd[:param1] = request[:param2] if !request[:param2].blank? and request[:cmd_type] == 'dial_up_num'
        cmd[:param2] = request[:param3] if !request[:param3].blank? and request[:cmd_type] == 'dial_up_num'
        cmd[:param3] = request[:param4] if !request[:param4].blank? and request[:cmd_type] == 'dial_up_num'
         
        @flag = false
        @flag = true unless request[:local_primary].blank?
        @flag = true unless request[:local_secondary].blank?
        @flag = true if not request[:global_primary].blank? and params[:global_default]
        @flag = true if not request[:global_secondary].blank? and params[:global_alt_default]
        
        if request[:cmd_type] == 'dial_up_num_glob_prim' and @flag == true
          cmd[:param1] = request[:local_primary] unless request[:local_primary].blank?
          cmd[:param2] = request[:local_secondary] unless request[:local_secondary].blank?
          glob_prim = DialUp.find(:first,:conditions => "dialup_type ='Global' and order_number = '1'")
          cmd[:param3] = glob_prim.phone_number if params[:global_default] and glob_prim
          cmd[:param3] = request[:global_primary] unless request[:global_primary].blank? and params[:global_default]
          glob_alt = DialUp.find(:first,:conditions => "dialup_type = 'Global' and order_number = '2'")
          cmd[:param4] = glob_alt.phone_number if params[:global_alt_default] and glob_alt
          cmd[:param4] = request[:global_secondary] unless request[:global_secondary].blank? and params[:global_alt_default]
          
        elsif request[:cmd_type] == 'dial_up_num_glob_prim' and @flag == false
          @success = false
          @message = 'Please Select at least one dialup number'

        # https://redmine.corp.halomonitor.com/issues/398
        # WARNING: not covered by cucumber
        #   request[:ids] can accept a mixture of range, and individual ids
        #   examples:
        #     id1
        #     id1-id5
        #     id1, id5, id7
        #   or, just mix all the definitions
        #     id1-id5, id6, id7-id9
        elsif request[ :cmd_type] == 'unregister'
          Device.unregister( request[ :ids ] ) # will be parsed within method call
          
        # https://redmine.corp.halomonitor.com/issues/3191
        # nothing to add here. it will automatically post to param1, param2
        end

        # # CHANGED: Re-factored
        # #   * used the new method "parse_integer_ranges" to parse all IDs
        # if /-/.match(request[:ids])
        #   create_cmds_for_range_of_devices(request[:ids], cmd)
        # elsif /,/.match(request[:ids]) 
        #   create_cmds_for_devices_separated_by_commas(request[:ids], cmd)
        # elsif @success == true                    
        #   create_cmd_for_single_id(request[:ids], cmd)
        # end
        #
        # New logic: DRYed. No need of private methods
        #   * parse ids in one call
        #   * collect @pending_cmds and use it as a conditionin the same call
        # WARNING: Needs code coverage
        if request[:ids].to_s.parse_integer_ranges.blank? # use to_s to make sure of string data type
          #
          # If given string does not yeild any integer values, complain
          @success = false
          @message = "Please provide valid device IDs in (#{ids})"
        else
          #
          # QUESTION: Please confirm the business logic.
          #   * If we issue a firmware upgrade to 1-5, 7-10 IDs
          #   * At least one pending command exist for even one of these IDs
          #   * Then firmware upgrade for all of these IDs are skipped
          if (@pending_cmds = MgmtCmd.pending( request[:ids], cmd[ :cmd_type ] )).length.zero?
            #
            # If any earlier command is pending, just error out. Un-conditionally.
            # QUESTION: Should we show error for each ID?
            request[:ids].to_s.parse_integer_ranges.each {|_id| MgmtCmd.create( cmd.merge( :device_id => _id)) }
            @success = true
          else
            #
            # We have some pending commands in the queue.
            # Business logic does not allow to fill the queue any further.
            @success = false
            @message = "Command not Queued up. Already have #{@pending_cmds.length} pending commands."
          end
        end
        
      else
        @success = false
        @message = 'Please provide device ids.'
      end
    end
    render :layout => false
  end
  
  def issue
    # 
    #  Tue Dec 14 00:14:59 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3859
    @firmware_upgrades = FirmwareUpgrade.find(:all, :order => 'id desc').paginate :per_page => 20, :page => params[:page]
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
    @user_begin_time = params[:begin_time]
    @user_end_time = params[:end_time]
    
    if !params[:begin_time].blank?
      @begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
    end
    if !params[:end_time].blank?
      @end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
    end
  end
  
  def delete
    MgmtCmd.delete(params[:id])
    render :nothing => true
  end

  private
 
  # Old logic
  #   * splitting the range into individual ids
  #   * collecting pending commands for all ids in range
  #   * creating the command only once, if there are no pending commands for any ids in range
  # New logic
  #   * Doing the same thing DRYed
  #
  # WARNING: Needs test coverage
  # these private methods are now replaced by the DRYed logic above
  #
  # def create_cmds_for_range_of_devices(ids, cmd)
  #   arr = ids.split('-')
  #   
  #   min = arr[0].to_i
  #   max = arr[1].to_i
  #   
  #   if min && max
  #     count = min
  #     while count <= max
  #       cmd[:device_id] = count
  #       
  #       @pending_cmds += MgmtCmd.pending( count, cmd[:cmd_type])
  #       # @pending_cmds += MgmtCmd.pending_server_commands_for_device_and_type(count, cmd[:cmd_type])
  #       if @pending_cmds.length == 0
  #         MgmtCmd.create(cmd)
  #       end
  #       
  #       count+=1
  #     end
  #   else
  #     @success = false
  #     @message = 'Please provide a min and max for the range of device ids.'
  #   end
  # end
  # 
  # def create_cmds_for_devices_separated_by_commas(ids, cmd)
  #   ids.split(',').each do |id|          
  #     if id
  #       cmd[:device_id] = id
  #       
  #       @pending_cmds += MgmtCmd.pending( id, cmd[:cmd_type])
  #       # @pending_cmds += MgmtCmd.pending_server_commands_for_device_and_type(id, cmd[:cmd_type])
  #       if @pending_cmds.length == 0
  #         MgmtCmd.create(cmd)
  #       end
  #     end
  #   end
  # end
  # 
  # def create_cmd_for_single_id(id, cmd)
  #   cmd[:device_id] = id
  #   
  #   @pending_cmds = MgmtCmd.pending( id, cmd[:cmd_type])
  #   # @pending_cmds = MgmtCmd.pending_server_commands_for_device_and_type(id, cmd[:cmd_type])
  #   if @pending_cmds.length == 0
  #     MgmtCmd.create(cmd)
  #   end
  # end
  
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
