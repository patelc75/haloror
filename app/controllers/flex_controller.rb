class FlexController < ApplicationController
  def chart
    # gather data from these models
    #@models = [Vital, SkinTemp, Step, Battery]
    @models = [Vital, SkinTemp, Battery]
    
    unless query = params[:ChartQuery]
      query = {}
    end
    
    # initialization
    if query[:userID] == nil
      query = {}
      query[:num_points] = '0'
      #query[:user_id] = 2
      query[:userID] = current_user.id
      query[:startdate] = Time.now - 600
      query[:enddate] = Time.now.to_s
      
      query[:startdate] = query[:startdate].to_s
    end
    
    query[:user_id] = query[:userID]
    
    if query[:enddate] == nil && query[:startdate] != nil
      query[:enddate] = Time.now.to_s
    end
    
    user = User.find(query[:user_id])
    #query[:startdate] = format_datetime(query[:startdate].to_time, user)
    #query[:enddate] = format_datetime(query[:enddate].to_time, user)
    
    data = {}
    
    if query[:enddate] and query[:startdate]
      if query[:num_points] == '0'
        data = discrete_chart_data(query)
        averaging = 'false'
      else
        data = average_chart_data(query)
        averaging = 'true'
      end
    end
    
    status = {}
    status[:connectivity] = 'Device Available' unless status[:connectivity] = get_status('connectivity', user)
    
    status[:battery_outlet_status] = 'Unknown' unless status[:battery_outlet_status] = get_status('battery_outlet_status', user)
    status[:battery_level_status] = 'Normal' unless status[:battery_level_status] = get_status('battery_level_status', user)
    
    
    
    #status[:battery] = get_status('battery', user)
    
    unless battery = Battery.find(:first)
      battery = {}
    end
    
    events = {}
    if query[:enddate] and query[:startdate]
      events = Event.find(:all, :conditions => "user_id = '#{query[:user_id]}' and timestamp <= '#{query[:enddate]}' and timestamp >= '#{query[:startdate]}'")    
    end
    
    if params[:test]
      render :partial => 'chart_data_test', :locals => {:data => data, :query => query, :user => user, :averaging => averaging, :events => events, :battery => battery, :last_reading => get_last_reading(query[:user_id]), :status => status}
    else
      render :partial => 'chart_data', :locals => {:data => data, :query => query, :user => user, :averaging => averaging, :events => events, :battery => battery, :last_reading => get_last_reading(query[:user_id]), :status => status}
    end
  end
  
  protected
  
  def discrete_chart_data(query)
    data = {}
    
    @models.each do |model|
      get_model_data(model,query).each do |row|
        if row[:timestamp]
          timestamp = row[:timestamp]
        else
          timestamp = row[:end_timestamp]
        end
        
        unless data[timestamp]
          data[timestamp] = []
        end
        
        data[timestamp] << row
      end
    end
    
    data
  end
  
  def get_model_data(model, query)
    model.find(:all, :conditions => "user_id = #{query[:user_id]} and timestamp <= '#{query[:enddate]}' and timestamp >= '#{query[:startdate]}'")
  #rescue ActiveRecord::StatementInvalid
    #model.find(:all, :conditions => "user_id = #{query[:user_id]} and end_timestamp <= '#{query[:enddate]}' and begin_timestamp >= '#{query[:startdate]}'")
  end
  
  def average_chart_data(query)
    #average_data(num_points, start_time, end_time, id, column)
    columns = {'Vital' => ['heartrate','activity'],'SkinTemp' => 'skin_temp','Step' => 'steps','Battery' => 'percentage'}
        
    
    data = {}
    
    @models.each do |model|
      columns[model.class_name].each do |column|
        averages, times = []
        if params[:optimize]
          averages, times = model.average_data_optimize(query[:num_points].to_i, query[:startdate].to_time, query[:enddate].to_time, query[:user_id], column, nil)
        else
          averages, times = model.average_data(query[:num_points].to_i, query[:startdate].to_time, query[:enddate].to_time, query[:user_id], column, nil)
        end
        i = 0
        times.each do |time|
          unless data[time]
            data[time] = []
          end
          
          row = {:type => model.class_name.to_s, column.to_sym => averages[i], :hrv => 0}
          
          data[time] << row
          
          i+=1
        end
      end
    end
    
    data
  end
  
  def get_last_reading(user_id)
    reading = {}
    
    if vitals = Vital.find(:first, :conditions => "user_id = #{user_id}")
      reading[:heartrate] = vitals.heartrate
      reading[:hr_min] = vitals.heartrate - vitals.hrv / 2
      reading[:hr_max] = vitals.heartrate + vitals.hrv / 2
      reading[:activity] = vitals.activity
    end
    
    if battery = Battery.find(:first, :conditions => "user_id = #{user_id}")
      reading[:battery] = battery.percentage
    end
    
    if skin_temp = SkinTemp.find(:first, :conditions => "user_id = #{user_id}")
      reading[:skin_temp] = skin_temp.skin_temp
    end
    
    if steps = Step.find(:first, :conditions => "user_id = #{user_id}")
      reading[:steps] = steps.steps
    end
    
    reading
  end
  
  def get_status(kind, user)
    event = nil
    user.events.each do |event|
      if event.alert_type and event.alert_type.alert_group[:group_type] == kind
        return event.alert_type.alert_type
      end
    end
    
    return false
  end
end