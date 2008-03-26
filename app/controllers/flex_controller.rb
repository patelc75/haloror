class FlexController < ApplicationController
  def chart
    # gather data from these models
    #@models = [Vital, SkinTemp, Step, Battery]
    @models = [Vital, SkinTemp, Battery]
    
    unless query = params[:ChartQuery]
      query = {}
      query[:num_points] = '0'
      #query[:user_id] = current_user.id
      query[:user_id] = 10
      query[:startdate] = Time.now - 600
      query[:enddate] = Time.now.to_s
      
      query[:startdate] = query[:startdate].to_s
    end
    
    query[:enddate] = Time.now unless query[:enddate]
    
    if query[:num_points] == '0'
      data = discrete_chart_data(query)
      averaging = 'false'
    else
      data = average_chart_data(query)
      averaging = 'true'
    end
    
    events = Event.find(:all, :conditions => "user_id = '#{query[:user_id]}' and timestamp <= '#{query[:enddate]}' and timestamp >= '#{query[:startdate]}'")    
    render :partial => 'chart_data', :locals => {:data => data, :query => query, :user => User.find(query[:user_id]), :averaging => averaging, :events => events, :battery => Battery.find(:first), :last_reading => get_last_reading(query[:user_id])}
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
        
        unless data[timestamp.to_s]
          data[timestamp.to_s] = []
        end
        
        data[timestamp.to_s] << row
      end
    end
    
    data
  end
  
  def get_model_data(model, query)
    model.find(:all, :conditions => "user_id = #{query[:user_id]} and timestamp <= '#{query[:enddate]}' and timestamp >= '#{query[:startdate]}'")
  rescue ActiveRecord::StatementInvalid
    model.find(:all, :conditions => "user_id = #{query[:user_id]} and end_timestamp <= '#{query[:enddate]}' and begin_timestamp >= '#{query[:startdate]}'")
  end
  
  def average_chart_data(query)
    #average_data(num_points, start_time, end_time, id, column)
    columns = {'Vital' => ['heartrate','activity'],'SkinTemp' => 'skin_temp','Step' => 'steps','Battery' => 'percentage'}
    
    
    data = {}
    
    @models.each do |model|
      columns[model.class_name].each do |column|
        averages, times = model.average_data(query[:num_points].to_i, query[:startdate].to_time, query[:enddate].to_time, query[:user_id], column, nil)
        
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
end