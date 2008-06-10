class Vital < ActiveRecord::Base
  DEVICE_CHEST_STRAP_TYPE = 'Halo Chest Strap'
  belongs_to :user
  
  def self.latest_data(num_points, id, column)	
    #sorts by ID instead of by timestamp
    vital = find(:all , 
      :limit => num_points, 
      :order => "id DESC", 
      :conditions => "user_id = '#{id}'").reverse
		
    #logger.debug{ "Vital.latest_data: vital =#{vital} \n" }

    if(vital.empty?)
      @series_data = Array.new(num_points, 0)  #results of averaging from database
      @categories = Array.new(num_points, 0)       
    elsif
      #@series_data = get_latest(vital)
      @series_data = vital.map {|a| a.send(column) }
      @categories =  vital.map {|a| a.timestamp.strftime("%H:%M:%S") }      
    end
	
    values = [@series_data,  @categories]
  end
  
  def self.average_data_optimize(num_points, start_time, end_time, id, column, format)
    RAILS_DEFAULT_LOGGER.info "Vital::average_data_optimize"
    series_data = Array.new(num_points, 0)  #results of averaging from database
    categories = Array.new(num_points, 0) 
    interval = (end_time - start_time) / num_points #interval returned in seconds
    current_time = start_time
    current_point = 0   #the data point that we're currently on
 
    select = ""
    while current_point < num_points 
      
      if current_point == 0
        select << "select avg(#{column}) as average from #{table_name} where user_id = '#{id}' AND (timestamp >= '#{current_time}' AND timestamp < '#{current_time + interval}') "
      else
        select << " UNION ALL select avg(#{column}) as average from #{table_name} where user_id = '#{id}' AND (timestamp >= '#{current_time}' AND timestamp < '#{current_time + interval}') "
      end
      current_time = current_time + interval
      current_point = current_point + 1
    end
    current_time = start_time
    current_point = 0
    connection.select_all(select).collect do |result|
      current_time = current_time + interval
      RAILS_DEFAULT_LOGGER.debug result.length
      RAILS_DEFAULT_LOGGER.debug result.inspect
      RAILS_DEFAULT_LOGGER.debug current_time.inspect
      average = result['average']
      if(average == nil)
        series_data[current_point] = 0
      elsif
        series_data[current_point] = average.to_f.round(1)
      end

      if format
        categories[current_point] = current_time.strftime(format)  
      else
        categories[current_point] = current_time
      end

      current_point = current_point + 1

    end
    values = [series_data,  categories]
    
  end
  
  def self.sum_data(num_points, start_time, end_time, id, column, format)
    @series_data = Array.new(num_points, 0)  #results of averaging from database
    @categories = Array.new(num_points, 0) 
    interval = (end_time - start_time) / num_points #interval returned in seconds
    current_time = start_time
    current_point = 0   #the data point that we're currently on
    
    while current_point < num_points
      condition = "begin_timestamp >= '#{current_time}' AND begin_timestamp < '#{current_time + interval}' AND user_id = '#{id}'"
    
      sum = sum(column, :conditions => condition)
        
      current_time = current_time + interval
    
      if(sum == nil)
        @series_data[current_point] = 0
      elsif
        @series_data[current_point] = sum.to_f.round(1)
      end
          
      if format
        @categories[current_point] = current_time.strftime(format)  
      else
        @categories[current_point] = current_time
      end
       
      current_point = current_point + 1
    end 
    
    values = [@series_data,  @categories]
  end
  
  def self.average_data(num_points, start_time, end_time, id, column, format)
    @series_data = Array.new(num_points, 0)  #results of averaging from database
    @categories = Array.new(num_points, 0) 
    interval = (end_time - start_time) / num_points #interval returned in seconds
    current_time = start_time
    current_point = 0   #the data point that we're currently on
    
    while current_point < num_points
      condition = "timestamp >= '#{current_time}' AND timestamp < '#{current_time + interval}' AND user_id = '#{id}'"
    
      #before inheritance
      #average = Heartrate.average(:heartrate, :conditions => condition)
    
      #after inheritance
      #average = get_average(condition)    #using polymorphism
      #average = average("'#{column}'", condition) #if column is passed in as :heartrate
      average = average(column, :conditions => condition)
        
      current_time = current_time + interval
    
      #@series_data[current_point] = format_average(average)
      if(average == nil)
        @series_data[current_point] = 0
      elsif
        @series_data[current_point] = average.round(1)
      end
          
      if format
        @categories[current_point] = current_time.strftime(format)  
      else
        @categories[current_point] = current_time
      end
       
      current_point = current_point + 1
      #@averages_array << round_to(average, 1)
      #@averages_array <<  ((average * 10).truncate.to_f / 10)
      #@labels_array << current_time.strftime("%H:%M:%S")
    end 
    
    #     puts "above the loop"
    #     #for debugging
    #     @averages_array.each_with_index() do |x, i| 
    #       puts x, @labels_array[i]
    #       puts "HW"
    #     end
      
    values = [@series_data,  @categories]
  end

  
  
  def self.method_missing(methId, *args)
    method = methId.id2name.to_s
    method_action = method[0...method.index("_").to_i]
    case method_action
    when "average"
      column = method[method.index("_").to_i + 1..method.length]
      arguments = String.new
      arguments += args.join(", ") || nil.to_s
      # arguments += " and " if !arguments.empty?
      # arguments += 
      #ActiveRecord::Base.class_eval("#{column}.average(#{arguments})")
      class_eval("average(:#{column})")
    end
  end

  # Creates alerts for users that have become unavailable
  def Vital.job_detect_unavailable_devices
    ActiveRecord::Base.logger.debug("Vital.job_detect_unavailable_devices running at #{Time.now}")

    ## Find devices that were previously signaling errors but have
    ## come back Online.
    conds = []
    conds << "reconnected_at is null"
    conds << "device_id in (select v.id from latest_vitals v where v.updated_at >= now() - interval '#{DEVICE_UNAVAILABLE_TIMEOUT} minutes')"
    conds << "device_id in (select d.id from devices d where d.device_type = '#{DEVICE_CHEST_STRAP_TYPE}')"
    conds << "device_id in (select status.id from device_strap_status status where is_fastened > 0)"
    
    alerts = DeviceUnavailableAlert.find(:all,
      :conditions => conds.join(' and '))
    alerts.each do |alert|
      DeviceUnavailableAlert.transaction do
        DeviceAvailableAlert.create(:device => alert.device)
        alert.reconnected_at = Time.now
        alert.save!
      end
    end

    # We need to find all devices where:
    # a) Vitals have not been posted to for a specific interval
    # AND 
    # b) the chest strap is “fastened”
    conds = []
    conds << "id in (select v.id from latest_vitals v where v.updated_at < now() - interval '#{DEVICE_UNAVAILABLE_TIMEOUT} minutes')"
    conds << "id in (select d.id from devices d where d.device_type = '#{DEVICE_CHEST_STRAP_TYPE}')"
    conds << "id in (select status.id from device_strap_status status where is_fastened > 0)"

    devices = Device.find(:all,
      :conditions => conds.join(' and '))

    devices.each do |device|
      begin
        Vital.process_device_unavailable(device)
      rescue Exception => e
        logger.fatal("Error processing unavailable device alert for device #{device.inspect}: #{e}")
        raise e if ENV['RAILS_ENV'] == "development" || ENV['RAILS_ENV'] == "test"
      end
    end
    ActiveRecord::Base.verify_active_connections!()
  end

  private
  def self.process_device_unavailable(device)
    alert = DeviceUnavailableAlert.find(:first,
      :order => 'created_at desc',
      :conditions => ['reconnected_at is null and device_id = ?', device.id])

    if alert
      alert.number_attempts += 1
      alert.save!
    else
      alert = DeviceUnavailableAlert.new
      alert.device = device
      alert.save!
    end
  end


end
