class DevicesController < ApplicationController
  before_filter :authenticate_admin?
  def stats
    @device = Device.find(params[:id])
  end
  
  def data
    @device = Device.find(params[:id])
    @periods = {}
    
    i = 0
    now = Date.today.to_time
    while i < 30
      time = now.ago(i*86400)
      @periods[time] = get_data(params[:type], time, time.tomorrow, @device)
      i += 1
    end
    
    render :layout => false
  end
  
  def get_data(type, start_time, end_time, device)
    return not_worn_data(start_time,end_time,device) if type == 'not_worn'
    return out_of_range_data(start_time,end_time,device) if type == 'out_of_range'
    return battery_charge_data(start_time,end_time,device) if type == 'battery_charge'
  end
  
  def not_worn_data(start_time,end_time,device)
    removed_before = StrapRemoved.find(:first, :conditions => "timestamp < '#{start_time}' and device_id = '#{device.id}'")
    fastened_before = StrapFastened.find(:first, :conditions => "timestamp < '#{start_time}' and device_id = '#{device.id}'")
    
    cur_time = 0
    
    # does strap begin day removed?
    if removed_before and fastened_before
      if removed_before.timestamp < fastened_before.timestamp
        cur_time = start_time.to_i
      end 
    end
    
    events = []
    
    StrapRemoved.find(:all, :conditions => "timestamp > '#{start_time}' and timestamp < '#{end_time}' and device_id = '#{device.id}'").reverse.each do |event|
      events << event
    end
    
    StrapFastened.find(:all, :conditions => "timestamp > '#{start_time}' and timestamp < '#{end_time}' and device_id = '#{device.id}'").reverse.each do |event|
      events << event
    end
    
    total_time = 0
    
    events.sort_by { |event| event[:timestamp] }.each do |event|
      if event.type.class_name == 'StrapRemoved'
        cur_time = event.timestamp.to_i
      else
        total_time += event.timestamp.to_i - cur_time.to_i
      end
      
      @event = event
    end
    
    # time till end of day      
    if @event and @event.type.class_name == 'StrapRemoved'
      total_time += end_time.to_i - @event.timestamp.to_i
    end
    
    if total_time > 0
      total_time = total_time.to_f / 60 / 60
    else
      0
    end
  end
  
  def out_of_range_data(start_time,end_time,device)
    unavailable_before = DeviceUnavailableAlert.find(:first, :conditions => "created_at < '#{start_time}' and device_id = '#{device.id}'")
    available_before = DeviceAvailableAlert.find(:first, :conditions => "created_at < '#{start_time}' and device_id = '#{device.id}'")
    
    cur_time = 0
    
    # does strap begin day out of range?
    if unavailable_before and available_before
      if unavailable_before.created_at < available_before.created_at
        cur_time = start_time.to_i
      end 
    end
    
    events = []
    
    DeviceUnavailableAlert.find(:all, :conditions => "created_at > '#{start_time}' and created_at < '#{end_time}' and device_id = '#{device.id}'").reverse.each do |event|
      events << event
    end
    
    DeviceAvailableAlert.find(:all, :conditions => "created_at > '#{start_time}' and created_at < '#{end_time}' and device_id = '#{device.id}'").reverse.each do |event|
      events << event
    end
    
    total_time = 0
    
    events.sort_by { |event| event[:created_at] }.each do |event|
      if event.type.class_name == 'DeviceUnavailableAlert'
        cur_time = event.created_at.to_i
      else
        total_time += event.created_at.to_i - cur_time.to_i
      end
      
      @event = event
    end
    
    # time till end of day
    if @event and @event.type.class_name == 'DeviceUnavailableAlert'
      total_time += end_time.to_i - @event.created_at.to_i
    end
    
    if total_time > 0
      total_time = total_time.to_f / 60 / 60
    else
      0
    end
  end
  
  def battery_charge_data(start_time,end_time,device)
    plugged_before = BatteryPlugged.find(:first, :conditions => "timestamp < '#{start_time}' and device_id = '#{device.id}'")
    unplugged_before = BatteryUnplugged.find(:first, :conditions => "timestamp < '#{start_time}' and device_id = '#{device.id}'")
    
    cur_time = 0
    
    # does strap begin day removed?
    if plugged_before and unplugged_before
      if plugged_before.timestamp < unplugged_before.timestamp
        cur_time = start_time.to_i
      end 
    end
    
    events = []
    
    BatteryPlugged.find(:all, :conditions => "timestamp > '#{start_time}' and timestamp < '#{end_time}' and device_id = '#{device.id}'").reverse.each do |event|
      events << event
    end
    
    BatteryUnplugged.find(:all, :conditions => "timestamp > '#{start_time}' and timestamp < '#{end_time}' and device_id = '#{device.id}'").reverse.each do |event|
      events << event
    end
    
    total_time = 0
    
    events.sort_by { |event| event[:timestamp] }.each do |event|
      if event.type.class_name == 'BatteryPlugged'
        cur_time = event.timestamp.to_i
      else
        total_time += event.timestamp.to_i - cur_time.to_i
      end
      
      @event = event
    end
    
    # time till end of day      
    if @event and @event.type.class_name == 'BatteryPlugged'
      total_time += end_time.to_i - @event.timestamp.to_i
    end
    
    if total_time > 0
      total_time = total_time.to_f / 60 / 60
    else
      0
    end
  end
end
