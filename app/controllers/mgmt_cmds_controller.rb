class MgmtCmdsController < ApplicationController
  # POST /mgmt_cmds
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
    
    # Call correct method in device model (if applicable)
    
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
          #user_id = device.register_user 
          user_id = device.users.first.id
          cmd.user_id = user_id
        else
          cmd.user_id = device.users.first.id
        end
      end
    end
    
    cmd.save
    
    
    
    # 3. Create mgmt_response
    response = MgmtResponse.new
    response.mgmt_cmd_id = cmd.id
    response.timestamp_server = Time.now
    response.save
    
    render :layout =>false, :partial => "management/response", :locals => {:response => response}
  end
  
  def create_many
    @success = true
    @message = 'Command created!'
    
    request = params[:management_cmd_device]
    
    if !request[:cmd_type].empty? && !request[:ids].empty?
      cmd = {}
      cmd[:cmd_type] = request[:cmd_type]
      cmd[:cmd_id] = params[request[:cmd_type].to_sym]
      cmd[:timestamp_initiated] = Time.now
      cmd[:originator] = 'server'
    
      if /-/.match(request[:ids])     # range of device ids
        arr = request[:ids].split('-')
      
        min = arr[0].to_i
        max = arr[1].to_i
        
        if min && max
          count = min
          while count <= max
            cmd[:device_id] = count
        
            MgmtCmd.create(cmd) unless MgmtCmd.find_by_device_id(count)
            count+=1
          end
        else
          @success = false
          @message = 'Please provide a min and max for the range of device ids.'
        end
      elsif /,/.match(request[:ids])  # multiple device ids
        request[:ids].split(',').each do |id|          
          if id
            cmd[:device_id] = id
            MgmtCmd.create(cmd) unless MgmtCmd.find_by_device_id(id)
          end
        end
      else                            # single device id
        cmd[:device_id] = request[:ids]
        MgmtCmd.create(cmd) unless MgmtCmd.find_by_device_id(request[:ids])
      end
    else
      @success = false
      if !request[:cmd_type]        
        @message = 'Please select a command type.'
      else
        @message = 'Please provide device ids.'
      end
    end
    
    render :layout => false
  end
  
  def delete
    MgmtCmd.delete(params[:id])
    render :nothing => true
  end
end
