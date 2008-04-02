class Vital < ActiveRecord::Base

  belongs_to :user
  
  def self.latest_data(num_points, id, column)	
    vital = find(:all , 
      :limit => num_points, 
      :order => "timestamp DESC", 
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
  
  def self.average_data(num_points, start_time, end_time, id, column, format)
    @series_data = Array.new(num_points, 0)  #results of averaging from database
    @categories = Array.new(num_points, 0) 
    interval = (end_time - start_time) / num_points #interval returned in seconds
    current_time = start_time
    current_point = 0   #the data point that we're currently on

    while current_point < num_points
      condition = "timestamp > '#{current_time}' AND timestamp < '#{current_time + interval}' AND user_id = '#{id}'"

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
    ## come back online.
    sql = 'update device_unavailable_alerts set reconnected_at = now() where reconnected_at is null and user_id in ' <<
          " (select id from user_strap_status where is_fastened > 0) "
    Vital.connection.execute(sql)

    # We need to find all users where:
    #
    # a) Vitals have not been posted to for a specific interval
    # AND 
    # b) the chest strap is “fastened”
    conds = []
    conds << "id in (select v.device_id from latest_vitals v where v.updated_at < now() - interval '#{MgmtQuery::MINUTES_INTERVAL} minutes')"
    conds << "id in (select du.device_id from user_strap_status uss, devices_users du where uss.is_fastened > 0 and uss.user_id = du.user_id)"

    devices = Device.find(:all,
                          :conditions => conds.join(' and '))

    devices.each do |device|
      begin
        Vital.process_device_unavailable(device)
      rescue Exception => e
        logger.fatal("Error processing unavailable device alert for device #{device.inspect}: #{e}")
        raise e if ENV['RAILS_ENV'] == "development"
      end
    end
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
