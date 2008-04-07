class DevicesController < ApplicationController
  def stats
    @device = Device.find(params[:id])
  end
  
  def data
    @device = Device.find(params[:id])
    @periods = {}
    
    i = 0
    now = Date.today.to_time
    while i < 1
      time = now.ago(i*86400)
      @periods[time] = get_data(params[:type], time, time.tomorrow, @device)
      i += 1
    end
    
    render :layout => false
  end
  
  def get_data(type, start_time, end_time, device)
    if type == 'not_worn'
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
      if @event.type.class_name == 'StrapRemoved'
        total_time += end_time.to_i - event.timestamp.to_i
      end
      
      total_time = total_time.to_f / 60 / 60
    end
  end
end
