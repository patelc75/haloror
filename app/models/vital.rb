class Vital < ActiveRecord::Base
  belongs_to :user # WARNING: what is this association?
  has_many :users, :class_name => "User", :foreign_key => "last_vital_id"
  
  named_scope :few, lambda {|*args| { :limit => (args.flatten.first || 5) }}
  named_scope :till_now, :conditions => ["timestamp <= ?", Time.now]
  named_scope :recent_on_top, :order => 'timestamp DESC'
  named_scope :where_user_id, lambda {|arg| { :conditions => {:user_id => arg} }}
  
  # # cache trigger
  # # saves the latest vital status in users table
  # def after_save
  #   if (user = User.find(user_id))
  #     user.last_vital_id = id
  #     user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
  #   end
  #   # User.update(user_id, {:last_vital_id => id})
  # end
  
  # 
  #  Tue Dec  7 23:24:25 IST 2010, ramonrails
  #   * FIXME: what is this used for?
  #   * "after_initialize" is a better alternative
  #   * all properties can also be in a hash. self.attributes = { :heartrate => 74, ... }
  #   * Why should model return itself at the end of a method call within itself?
  def self.new_initialize(random=false)
    model = self.new
    model.heartrate = 74
    model.hrv = 3
    model.activity = 60
    model.orientation = 60
    return model    
  end
  
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
  
  def adl
    if activity < MIN_ADL_RESTING_ACTIVITY 
      if user.get_wearable_type == "Belt Clip"
        "Resting"
      elsif (user.get_wearable_type == "Chest Strap" and
          orientation > MIN_ADL_RESTING_ORIENTATION and
          orientation < MAX_ADL_RESTING_ORIENTATION)
        "Resting"
      else
        "Not Resting"
      end
    else
      "Not Resting"
    end
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
      if (column == :heartrate)
        condition = "timestamp >= '#{current_time}' AND timestamp < '#{current_time + interval}' AND user_id = '#{id}' AND (heartrate > 0 AND heartrate IS NOT NULL)"
      else
        condition = "timestamp >= '#{current_time}' AND timestamp < '#{current_time + interval}' AND user_id = '#{id}'"
      end
    
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
    RAILS_DEFAULT_LOGGER.warn("Vital.job_detect_unavailable_devices running at #{Time.now}")
    ethernet_system_timeout = SystemTimeout.find_by_mode('ethernet')
    dialup_system_timeout   = SystemTimeout.find_by_mode('dialup')
    ## Find devices that were previously signaling errors but have
    ## come back Online.
    conds = []
    conds << "reconnected_at is null"
    conds << "(device_id in (select device_id from access_mode_statuses where mode = 'ethernet') OR device_id not in (select device_id from access_mode_statuses))"
    conds << "device_id in (select v.id from latest_vitals v where v.updated_at >= now() - interval '#{ethernet_system_timeout.device_unavailable_timeout_sec} seconds')"
    conds << "device_id in (select d.id from devices d where d.device_revision_id in (Select device_revisions.id from device_revisions inner join (device_models inner join device_types on device_models.device_type_id = device_types.id) on device_revisions.device_model_id = device_models.id Where device_types.device_type in ('Chest Strap', 'Belt Clip')))"
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

    # Do the same thing for dialup
    conds = []
    conds << "reconnected_at is null"
    conds << "device_id in (select device_id from access_mode_statuses where mode = 'dialup') "
    conds << "device_id in (select v.id from latest_vitals v where v.updated_at >= now() - interval '#{dialup_system_timeout.device_unavailable_timeout_sec} seconds')"
    conds << "device_id in (select d.id from devices d where d.device_revision_id in (Select device_revisions.id from device_revisions inner join (device_models inner join device_types on device_models.device_type_id = device_types.id) on device_revisions.device_model_id = device_models.id Where device_types.device_type in ('Chest Strap', 'Belt Clip')))"
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
    conds << "(id in (select device_id from access_mode_statuses where mode = 'ethernet') OR id not in (select device_id from access_mode_statuses))"
    conds << "id in (select v.id from latest_vitals v where v.updated_at < now() - interval '#{ethernet_system_timeout.device_unavailable_timeout_sec} seconds')"
    conds << "id in (select d.id from devices d where d.device_revision_id in (Select device_revisions.id from device_revisions inner join (device_models inner join device_types on device_models.device_type_id = device_types.id) on device_revisions.device_model_id = device_models.id Where device_types.device_type in ('Chest Strap', 'Belt Clip')))"
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
    
    # Do same thing for dialup
    conds = []
    conds << "id in (select device_id from access_mode_statuses where mode = 'dialup')"
    conds << "id in (select v.id from latest_vitals v where v.updated_at < now() - interval '#{dialup_system_timeout.device_unavailable_timeout_sec} seconds')"
    conds << "id in (select d.id from devices d where d.device_revision_id in (Select device_revisions.id from device_revisions inner join (device_models inner join device_types on device_models.device_type_id = device_types.id) on device_revisions.device_model_id = device_models.id Where device_types.device_type in ('Chest Strap', 'Belt Clip')))"
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
  end

  def Vital.job_detect_unavailable_devices2
    RAILS_DEFAULT_LOGGER.warn("Vital.job_detect_unavailable_devices running at #{Time.now}")
    
    # Find devices that were previously DeviceUnavailable but now available again   
    ['ethernet', 'dialup'].each do |_mode|        
      conds = []                               
      conds << "(device_id in (select device_id from access_mode_statuses where mode = '#{_mode}')" + (_mode == 'ethernet' ? " OR id not in (select device_id from access_mode_statuses))" : ")")
      conds << "device_id in (select v.id from latest_vitals v where v.updated_at >= now() - interval '#{SystemTimeout.send(_mode.to_sym).device_unavailable_timeout_sec} seconds')"    
      conds << "device_id IN (select id from devices where serial_number LIKE 'H1%' or serial_number LIKE 'H5%')"
      conds << "device_id in (select status.id from device_strap_status status where is_fastened > 0)"  #we are filtering on strap fastened because the strap off alert

      alerts = DeviceUnavailableAlert.find(:all, :conditions => conds.join(' and '))
      alerts.each do |alert|
        DeviceUnavailableAlert.transaction do
          DeviceAvailableAlert.create(:device => alert.device)
          alert.reconnected_at = Time.now 
          Vital.populate_debugging_fields(alert)          
          alert.save!
        end
      end
    end
    
    # Find devices where a) Vitals have not been posted to for a specific interval AND b) the chest strap is “fastened”
    ['ethernet', 'dialup'].each do |_mode|
                
      conds = []
      conds << "(id in (select device_id from access_mode_statuses where mode = '#{_mode}')" + (_mode == 'ethernet' ? " OR id not in (select device_id from access_mode_statuses))" : ")")
      conds << "id in (select v.id from latest_vitals v where v.updated_at < now() - interval '#{SystemTimeout.send(_mode.to_sym).device_unavailable_timeout_sec} seconds')"
      conds << "id IN (select id from devices where serial_number LIKE 'H1%' or serial_number LIKE 'H5%')"  
      conds << "id in (select status.id from device_strap_status status where is_fastened > 0)"  #we are filtering on strap fastened because the strap off alert      

      devices = Device.find(:all,  :conditions => conds.join(' and '))
      devices.each do |device|
        begin
          Vital.process_device_unavailable(device)
        rescue Exception => e
          logger.fatal("Error processing unavailable device alert for device #{device.inspect}: #{e}")
          raise e if ENV['RAILS_ENV'] == "development" || ENV['RAILS_ENV'] == "test"
        end
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
      Vital.populate_debugging_fields(alert)                
      alert.save!
    end
  end   
  
  def self.populate_debugging_fields(alert)
    lv = LatestVital.find(:first, :conditions => {:id => alert.device.id})
    alert.latest_vital_at = lv.updated_at if !lv.nil?      

    dss = DeviceStrapStatus.find(:first, :conditions => {:id => alert.device.id})  
    alert.is_fastened_at = dss.updated_at if !dss.nil?
    alert.is_fastened = dss.is_fastened if !dss.nil?                         

    ams = AccessModeStatus.find(:first, :conditions => {:device_id => alert.device.id})  
    alert.access_mode = ams.mode if !ams.nil?
  end
end
