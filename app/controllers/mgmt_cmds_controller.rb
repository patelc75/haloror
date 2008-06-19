class MgmtCmdsController < RestfulAuthController
  # POST /mgmt_cmds
  skip_before_filter :authenticated?
  before_filter :authenticated?, :only => [:create]
  
  #this create method is called for both outbound and inbound (server or device originated)
  def create
    registration_device_id = '4294967295'
    
    # 1. Create mgmt_cmd
    request = params[:management_cmd_device]
    
    cmd = MgmtCmd.new
    cmd.cmd_type = request[:cmd_type]    
    cmd.timestamp_initiated = request[:timestamp]
    cmd.device_id = request[:device_id] 
    
    if !params[:originator]
      cmd.originator = "device"
    else
      cmd.originator = params[:originator]
    end
    
    # for device_id, it is searched in the device table by serial num
    if cmd.cmd_type == 'device_registration' && request[:device_id] == registration_device_id  #create device
      unless device = Device.find_by_serial_number(request[:serial_num])
        device = Device.new
        device.serial_number = request[:serial_num]
        device.save
      end
      
      cmd.device_id = device.id
    end
    
    # link to user
    if request[:device_id] && request[:device_id] != registration_device_id
      if device = Device.find(request[:device_id])
        if cmd.cmd_type == 'user_registration'
          if(device.users.first)
            cmd.user_id = device.users.first.id
          else
            cmd.user_id = nil
          end
        end
      end
    end
    
    if(cmd.originator == "device")
      cmd.pending = false
    end
    
    cmd.save    
    
    # 3. Create mgmt_response
    response = MgmtResponse.new
    response.mgmt_cmds << cmd
    response.timestamp_server = Time.now
    response.save
    
    render :layout =>false, :partial => "management/response", :locals => {:response => response}
  end
  
  def create_many
    @success = true
    @message = 'Command created!'
    @pending_cmds = []
    
    request = params[:management_cmd_device] #from the issue commands form
    
    if request[:cmd_type] == nil
      @success = false
      @message = 'Please select a command type.'
    else
      if !request[:ids].empty?
        cmd = {}
        cmd[:cmd_type] = request[:cmd_type]
        cmd[:cmd_id] = params[request[:cmd_type].to_sym]
        cmd[:timestamp_initiated] = Time.now
        cmd[:originator] = 'server'
      
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
end 
