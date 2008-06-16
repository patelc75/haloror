class FlexController < ApplicationController
  def chart
    @query = {}

    # gather data from these models
    @models = [Vital, SkinTemp, Step, Battery]

    # array to store all user data in; users[0] is the default user
    @users = []

    # default statuses
    @default_connectivity_status = 'Device Available'  
    @default_battery_outlet_status = 'Unknown'
    @default_battery_level_status = 'Normal'
    
    # build query hash
    build_query_hash
    
    # gather data
    gather_data
    
    if params[:test]
      render :partial => 'chart_data_test', :locals => {:query => @query, :users => @users}
    else
      render :partial => 'chart_data', :locals => {:query => @query, :users => @users}
    end
  end
  
  protected
  
  def gather_data
    default_user = User.find(@query[:user_id])
    
    # get data for default user
    @users << get_data_for_user(default_user, false)
    
    # get lastreading for each user the default_user is a caregiver of
    default_user.is_caregiver_for_what.each do |patient|
      @users << get_data_for_user(patient)
    end
  end
  
  def get_data_for_user(user, last_reading_only = true)
    user_data = user
    averaging = @query[:num_points].to_i == 0 ? false : true
    
    # get vital data
    if !@query[:enddate].blank? and !@query[:startdate].blank? and !last_reading_only
      if averaging
        vital_data = average_chart_data
      else
        vital_data = discrete_chart_data
      end
    else
      vital_data = {}
    end
    
    user_data[:data_readings] = vital_data
    
    # get last reading
    user_data[:last_reading] = get_last_reading_for_user(user)
    
    # get connectivity status
    user_data[:status] = {}
    
    unless user_data[:status][:connectivity] = get_status('connectivity', user)
      user_data[:status][:connectivity] = @default_connectivity_status
    end
    
    # get battery status
    unless user_data[:status][:battery_outlet] = get_status('battery_outlet_status', user)
      user_data[:status][:battery_outlet] = @default_battery_outlet_status
    end
    
    unless user_data[:status][:battery_level] = get_status('battery_level_status', user)
      user_data[:status][:battery_level] = @default_battery_level_status
    end
    
    # get last battery reading
    unless user_data[:battery] = Battery.find(:first, :order => 'id desc')
      user_data[:battery] = {}
    end
    
    # get events
    user_data[:events] = Event.find(:all, :conditions => "user_id = '#{@query[:user_id]}'", :order => 'timestamp desc', :limit => 10)
    
    return user_data
  end
  
  def discrete_chart_data
    data = {}
    
    @models.each do |model|
      get_model_data(model).each do |row|
        if row[:timestamp]
          timestamp = row[:timestamp]
        else
          timestamp = row[:begin_timestamp]
        end
        
        unless data[timestamp]
          data[timestamp] = []
        end
        
        data[timestamp] << row
      end
    end
    
    data
  end
  
  def get_model_data(model)
    #find() defaults to order by id (not order by timestamp)
    if model.class_name == "Step"
      model.find(:all, :conditions => "user_id = #{@query[:user_id]} and begin_timestamp < '#{@query[:enddate]}' and begin_timestamp >= '#{@query[:startdate]}'")
    else
      model.find(:all, :conditions => "user_id = #{@query[:user_id]} and timestamp < '#{@query[:enddate]}' and timestamp >= '#{@query[:startdate]}'")
    end
    #rescue ActiveRecord::StatementInvalid
    #model.find(:all, :conditions => "user_id = #{query[:user_id]} and end_timestamp <= '#{query[:enddate]}' and begin_timestamp >= '#{query[:startdate]}'")
  end
  
  def average_chart_data
    #average_data(num_points, start_time, end_time, id, column)
    columns = {'Vital' => ['heartrate','activity'],'SkinTemp' => 'skin_temp','Step' => 'steps','Battery' => 'percentage'}
        
    
    data = {}
    
    @models.each do |model|
      columns[model.class_name].each do |column|
        averages, times = []
        if !params[:optimize].blank?
          averages, times = model.average_data_optimize(@query[:num_points].to_i, @query[:startdate].to_time, @query[:enddate].to_time, @query[:user_id], column, nil)
        else
          if model.class_name == "Step"
            averages, times = model.sum_data(@query[:num_points].to_i, @query[:startdate].to_time, @query[:enddate].to_time, @query[:user_id], column, nil)
          else
            averages, times = model.average_data(@query[:num_points].to_i, @query[:startdate].to_time, @query[:enddate].to_time, @query[:user_id], column, nil)
          end
          
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
    
    return data
  end
  
  def get_last_reading_for_user(user)
    reading = {}
    
    if vitals = Vital.find(:first, :conditions => "user_id = #{user.id}", :order => 'id desc')
      reading[:heartrate] = vitals[:heartrate]
      
      if vitals.hrv
        reading[:hr_min] = vitals.heartrate - vitals.hrv / 2
        reading[:hr_max] = vitals.heartrate + vitals.hrv / 2
      else
        reading[:hr_min] = nil
        reading[:hr_max] = nil
      end
      
      reading[:activity] = vitals.activity
    end
    
    if battery = Battery.find(:first, :conditions => "user_id = #{user.id}", :order => 'id desc')
      reading[:battery] = battery.percentage
    end
    
    if skin_temp = SkinTemp.find(:first, :conditions => "user_id = #{user.id}", :order => 'id desc')
      reading[:skin_temp] = skin_temp.skin_temp
    end
    
    if steps = Step.find(:first, :conditions => "user_id = #{user.id}", :order => 'id desc')
      reading[:steps] = steps.steps
    end
    
    return reading
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
  
  def build_query_hash
    unless @query = params[:ChartQuery]
      @query = {}
    end
    
    # if no user id from chart, we want to run initialization
    initialize_chart if @query[:userID].nil?
    
    # map userID to user_id
    @query[:user_id] = @query[:userID]
    
    @query[:enddate] = Time.now if @query[:enddate].blank? && !@query[:startdate].blank?
  end
  
  def initialize_chart
    @query[:num_points] = 0                        # we want discreet data
    @query[:userID] = current_user.id              # default user is the one who's currently logged in
    @query[:enddate] = Time.now                    # enddate is now
    @query[:startdate] = @query[:enddate] - 600   # startdate is enddate - 10 minutes
  end
end