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
    vital_data = nil
    # get vital data
    if !@query[:enddate].blank? and !@query[:startdate].blank? and !last_reading_only
      if averaging 
        interval = (@query[:enddate].to_time - @query[:startdate].to_time) / @query[:num_points].to_i
        vital_data = average_data_record(user, interval, @query[:num_points].to_i, @query[:startdate].to_time)
        #  vital_data = average_chart_data
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
    
    unless user_data[:status][:connectivity] 
      user_data[:status][:connectivity] = Event.get_connectivity_state_by_user(user)
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
      time_previous = nil
      get_model_data(model).each do |row|
        if row[:timestamp]
          timestamp = row[:timestamp]
        else
          timestamp = row[:begin_timestamp]
        end
        
        move_on = false
        if time_previous == timestamp
          move_on = true
        end
        time_previous = timestamp
        unless move_on
          unless data[timestamp]
            data[timestamp] = []
          end
          data[timestamp] << row
        end
      end
    end
    
    data
  end
  
  def get_model_data(model)
    #find() defaults to order by id (not order by timestamp)
    if model.class_name == "Step"
      model.find(:all, :order => 'begin_timestamp desc', :conditions => "user_id = #{@query[:user_id]} and begin_timestamp < '#{@query[:enddate]}' and begin_timestamp >= '#{@query[:startdate]}'")
    else
      model.find(:all, :order => 'timestamp desc', :conditions => "user_id = #{@query[:user_id]} and timestamp < '#{@query[:enddate]}' and timestamp >= '#{@query[:startdate]}'")
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
        if model.class_name == "Step"
          averages, times = model.sum_data(@query[:num_points].to_i, @query[:startdate].to_time, @query[:enddate].to_time, @query[:user_id], column, nil)
        else
          averages, times = model.average_data(@query[:num_points].to_i, @query[:startdate].to_time, @query[:enddate].to_time, @query[:user_id], column, nil)
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
      reading[:adl] = vitals.adl
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
    event_id_array = Event.connection.select_all("select max(events.id) as id from events inner join alert_types on events.event_type = alert_types.alert_type where  events.user_id = #{user.id} AND alert_types.id in (select alert_type_id from alert_groups_alert_types where alert_group_id = (select alert_groups.id from alert_groups where group_type = '#{kind}'))")
    if event_id_array.size > 0
      id_hash = event_id_array[0] 
      event_id = id_hash["id"]
      if !event_id.blank?
        event = Event.find(event_id)
        if event && event.event_type
          return event.event_type
        end
      end
    end
    # 
    # user.events.each do |event|
    #   if event.alert_type and event.alert_type.alert_group[:group_type] == kind
    #     return event.alert_type.alert_type
    #   end
    # end
    # 
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
  
  def average_data_record(user, interval, num_points, start_time)
    data = {}
    timestamp = nil
    select = "select * from average_data_record_vitals(#{user.id}, '#{interval} seconds', #{num_points}, '#{format_datetime(start_time, user)}')"
    Vital.connection.select_all(select).collect do |result|
      heart_rate = result['average_heartrate']
      if !heart_rate.blank?
        heart_rate = heart_rate.to_f.round(1)
      else
        heart_rate = 0
      end
      
      activity = result['average_activity']
      if !activity.blank?
        activity = activity.to_f.round(1)
      else
        activity = 0
      end
      
      hrv = result['average_hrv']
      if !hrv.blank?
        hrv = hrv.to_f.round(1)
      else
        hrv = 0
      end
      
      orientation = result['average_orientation']
      if !orientation.blank?
        orientation = orientation.to_f.round(1)
      else
        orientation = 0
      end
      vital_row = {:type => 'Vital', :heartrate => heart_rate, :hrv => hrv, :activity => activity, :orientation => orientation}
      timestamp = Time.parse(result['ts'])
      data[timestamp] = [] unless data[timestamp]
      data[timestamp] << vital_row
    end
    select = "select * from average_data_record(#{user.id}, '#{interval} seconds', #{num_points}, '#{format_datetime(start_time, user)}', 'skin_temps', 'skin_temp')"
    SkinTemp.connection.select_all(select).collect do |result|
      average = result['average']
      if !average.blank?
        average = average.to_f.round(1)
      else
        average = 0
      end
      skin_temp_row = {:type => 'SkinTemp', :skin_temp => average}
      timestamp = Time.parse(result['ts'])
      data[timestamp] = [] unless data[timestamp]
      data[timestamp] << skin_temp_row 
    end
    select = "select * from sum_data_record(#{user.id}, '#{interval} seconds', #{num_points}, '#{format_datetime(start_time, user)}', 'steps', 'steps')"
    Step.connection.select_all(select).collect do |result|
      sum_result = result['sum_result']
      if !sum_result.blank?
        sum_result = sum_result.to_f.round(1)
      else
        sum_result = 0
      end
      steps_row = {:type => 'Step', :steps => sum_result}
      timestamp = Time.parse(result['ts'])
      data[timestamp] = [] unless data[timestamp]
      data[timestamp] << steps_row
    end
    select = "select * from average_data_record(#{user.id}, '#{interval} seconds', #{num_points}, '#{format_datetime(start_time, user)}', 'batteries', 'percentage')"
    Battery.connection.select_all(select).collect do |result|
      average = result['average']
      if !average.blank?
        average = average.to_f.round(1)
      else
        average = 0
      end
      battery_percentage_row = {:type => 'Battery', :percentage => average}
      timestamp = Time.parse(result['ts'])
      data[timestamp] = [] unless data[timestamp]
      data[timestamp] << battery_percentage_row 
    end
    return data
  end
  
  
end
