module UtilityHelper
  include ServerInstance

  # ::PAYMENT_GATEWAY constant was causing issues at sdev
  #   :: must always be used to make sure the constant is accessible
  #
  #   this method can be used to resolve the issue, if not
  #
  def payment_gateway_server
    if defined?(::PAYMENT_GATEWAY)
      ::PAYMENT_GATEWAY
    else
      ActiveMerchant::Billing::Base.mode = (['production', 'staging'].include?(ENV['RAILS_ENV']) ? :production : :test)
      ActiveMerchant::Billing::AuthorizeNetGateway.new(
        :login => AUTH_NET_LOGIN, # global constants from environment file
        :password => AUTH_NET_TXN_KEY,
        :test => ['production', 'staging'].include?(ENV['RAILS_ENV'])
      )
    end
  end

  #  Wed Nov  3 04:41:09 IST 2010, ramonrails 
  #   FIXME: stop using this method. User model can handle this more RESTfully
  def self.change_password_by_user_id(user_id, password)
  	salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{User.find(user_id).login}--")

  	crypted_password = Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  
  	u = User.find(user_id)
  	u.crypted_password = crypted_password
  	u.salt = salt
  	u.save 
  end

  def self.change_password_by_login(login, password)
  	salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--")

  	crypted_password = Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  
  	u = User.find_by_login(login)
  	u.crypted_password = crypted_password
  	u.salt = salt
  	u.save
  end

  # ---------------------------------------
  
  # timestamp after <n> business hours from now
  # calculated as:
  #   business hours: monday to friday, 8am to 5pm CST (-5 hrs GMT)
  def business_hours_later( hours)
    now = Time.now # freeze it here for this cycle of call, or it keeps changing every second
    wanted = (hours.to_i.hours / 1.second) # convert hours to seconds
    available = available_work_seconds( now) # how much available today
    # if we have enough time today, just tell the time possible today
    # if we will run out of time today, check next working day, add run-over seconds to the start-of-day
    (available > wanted) ? ( now + wanted.seconds) : ( next_workday(now) + (wanted - available).seconds)
  end
  
  def today?( time)
    time = Time.zone.parse( time.to_s)
    !time.blank? and (time.year == Time.now.year && time.month == Time.now.month && time.day == Time.now.day)
  end
  
  def workday?( date = Time.now)
    time = Time.zone.parse( date.to_s )
    !time.blank? && time.wday.between?( 1, 5) # 1 = monday, 5 = Friday
  end

  def next_workday( time = Time.now)
    time = Time.zone.parse( time.to_s)
    if time.blank?
      nil
    else
      beginning_of_workday_on( time.wday.between?(0, 4) ? (time + 1.day) : (time + (8-time.wday).day) )
    end
  end
  
  def available_work_seconds( date = Time.now)
    time = Time.zone.parse( date.to_s)
    if time.blank?
      0
    else
      time = Time.now if today?( time)
      end_of_day = end_of_workday_on( time)
      ((!end_of_day.blank? && time.wday.between?( 1, 5) && (time < end_of_day)) ? (end_of_day - time) : 0)
    end
  end

  def end_of_workday_on( time = nil)
    time = Time.zone.parse( time.to_s)
    time.blank? ? nil : Time.zone.parse("#{time.year}-#{time.month}-#{time.day} 17:00:00 CST")
  end

  def beginning_of_workday_on( time = nil)
    time = Time.zone.parse( time.to_s)
    time.blank? ? nil : Time.zone.parse("#{time.year}-#{time.month}-#{time.day} 08:00:00 CST")
  end

  #--------------------------------
  
  #return the offset for this time zone as a string
  def self.offset_for_time_zone(user)
    #tz = TZInfo::Timezone.get('America/Chicago')
    tz = Time.zone
    if user and user.profile and user.profile.time_zone
      tz = user.profile.tz
    end
    period = tz.current_period
    return period.utc_total_offset() / 60 / 60
    rescue 
	    "There is not any timezone for this user"
  end
  
  def offset_in_hours(datetime)
    #lookup = {-7 => 'PST', -6 => 'MST', -5 => 'CST', -4 => 'EST'}
    
    #original_datetime = datetime
    #offset = datetime.hour - original_datetime.hour
    
    #if datetime.day != original_datetime.day  
      #offset = offset - 24
    #end
    
    #return "#{newdate} #{offset} #{datetime.strftime("%Y")}"
  end
  
  def self.user_time_zone_to_utc(user_time)
  	user_time = Time.zone.parse(user_time)
  	user_time = user_time.utc
  end
  
  def self.format_datetime_flex(datetime,user)
    #return datetime if !datetime.respond_to?(:strftime)
    
    # Any interaction between the server and flex should
    # pass information back and forth as UTC.
    # I disabled the tzinfo translation.  -Neal 9/30/08
    return datetime.getutc.strftime("%a %b %d %H:%M:%S %Z %Y")
  end

  # 
  #  Mon Feb 14 21:11:24 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4190
  def self.format_datetime( datetime, user = nil, format = :date_time_timezone)
    #this line is causing problems in Rufus (without tzinfo) and don't really need it anyway
    #return datetime if !datetime.respond_to?(:strftime)

    tz = ((!user.blank? && !user.profile.blank? && !user.profile.time_zone.blank?) ? user.profile.tz : Time.zone)
    # if !user.blank? && !user.profile.blank? && !user.profile.time_zone.blank?
    #   tz = user.profile.tz
    # else
    #   #tz = TZInfo::Timezone.get('America/Chicago')    #deprecated tzinfo
    #   tz = Time.zone
    # end

    #   * commented-out code and working block here , are same
    #   * just a bit of refactoring
    if !datetime.blank? && datetime.respond_to?(:in_time_zone)
      #   * formatted or not
      if format.blank?
        datetime.in_time_zone(tz)
      else
        datetime.in_time_zone(tz).send( ((format == :date_time_timezone) ? :to_s : :strftime), format)
      end
    else
      datetime # at least return some date time
    end
    #   * same code above, just refactored
    #   
    # #see environment.rb for examples of formats
    # if (format == :date_time_timezone)
    #   if !datetime.blank? && datetime.respond_to?(:in_time_zone)
    #     #   * formatted or not
    #     format.blank? ? datetime.in_time_zone(tz) : datetime.in_time_zone(tz).to_s(format)
    #   else
    #     datetime # at least return some date time
    #   end
    # else
    #   if !datetime.blank? && datetime.respond_to?(:in_time_zone)
    #     #   * formatted or not
    #     format.blank? ? datetime.in_time_zone(tz) : datetime.in_time_zone(tz).strftime(format)
    #   else
    #     datetime # at least return some date time
    #   end
    # end
    #datetime = tz.utc_to_local(datetime)
  end
    
  def self.get_stacktrace(exception)
    if !exception.backtrace.blank?
      return exception.backtrace.join("\n")
    end
    return ""
  end
  
  def self.log_message(message, exception=nil) 
    if !exception.nil?
      message  = "[#{ServerInstance.current_host_short_string}]#{message}\n#{UtilityHelper.get_stacktrace(exception)}"
    end
    RAILS_DEFAULT_LOGGER.warn(message)
    safe_send_email(message, 'exceptions@halomonitoring.com')
  end

  def self.log_message_critical(message, exception=nil) 
    if !exception.nil?
      message  = "[#{ServerInstance.current_host_short_string}]#{message}\n#{UtilityHelper.get_stacktrace(exception)}"
    end
    RAILS_DEFAULT_LOGGER.warn(message)  
    safe_send_email(message, 'exceptions_critical@halomonitoring.com')
  end
    
  def self.safe_send_email(message, to)
    begin
      params_hash = {:mail => "#{ServerInstance.current_host()}.Message = #{message}", 
                        :to => to, 
                        :from => 'no-reply@halomonitoring.com', 
                        :priority => 100 }
      if (ENV['RAILS_ENV'] == 'production' or ENV['RAILS_ENV'] == 'staging')
        email = Email.new(params_hash)
        ar_sendmail = ActionMailer::ARSendmail.new  
        ar_sendmail.deliver([email])
      else
        email = Email.create(params_hash)
      end
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("Exception in UtilityHelper.self.safe_send_email #{e}")
    rescue
      RAILS_DEFAULT_LOGGER.warn("Exception in UtilityHelper.self.safe_send_email")
    end
  end
  
  def self.get_timezone_offset(user)
    now = Time.now()
    
    if user and user.profile and user.profile.time_zone
      tz = user.profile.tz
    else
      #tz = TZInfo::Timezone.get('America/Chicago')
      tz = Time.zone
    end
    datetime = now.in_time_zone(tz) if now != nil 
    #datetime = tz.utc_to_local(now)
    offset = datetime.hour - now.hour
      
    if datetime.day != now.day  
      offset = offset - 24
    end
    return offset.to_s
  end
  
  def self.camelcase_to_spaced(word)
    word.gsub(/([A-Z])/, " \\1").strip
  end
  
  def self.camelcase_to_underscored(word)
    word.gsub!(/([A-Z])/, "_\\1")
    return word[1, word.size - 1]
  end
  
  def self.seconds_format(seconds)
    days = nil
    hours = nil
    minutes = nil
    one_minute = 60
    one_hour = one_minute * 60
    one_day = one_hour * 24    
    if one_day < seconds
      days = seconds / one_day
      seconds = seconds - (days * one_day)
    end
    if one_hour < seconds
      hours = seconds / one_hour
      seconds = seconds - (hours * one_hour)
    end
    if one_minute < seconds
      minutes = seconds / one_minute
      seconds = seconds - (minutes * one_minute)
    end
    time_string = ""
    time_string = time_string + "#{days.round(2)} days " if days
    time_string = time_string + "#{hours.round(2)} hours " if hours
    time_string = time_string + "#{minutes.round(2)} minutes " if minutes
    time_string = time_string + "#{seconds.round(2)} seconds " if seconds > 0
    if time_string.blank?
      return '0 seconds'
    end
    return time_string
  end

  def self.models()
    Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
    @models = Object.subclasses_of(ActiveRecord::Base) #get all the tables in the database
    @models.sort_by { |m| m.class_name }.each do |m| #loop through them
      print m.class_name + ", "
    end    
  end
  
  def self.models_with_column(column)
    Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
    @models = Object.subclasses_of(ActiveRecord::Base) #get all the tables in the database
    @models.sort_by { |m| m.class_name }.each do |m| #loop through them
      if ActiveRecord::Base.connection.tables.include?(m.class_name.underscore.pluralize) and m.columns_hash.has_key?(column)
        puts m.class_name
      end
    end
  end
  
  def self.validate_event(event)
    if event.user_id < 1 or event.user_id == nil or event.user == nil 
      raise "#{event.class.to_s}: user_id = #{event.user_id} is invalid"
    elsif event.device_id < 1 or event.device_id == nil or event.device == nil
      raise "#{event.class.to_s}: device_id = #{event.device_id} does not exist"
    else
      true
    end
  end
  
  def self.validate_event_user(event)
    if event.user.blank? # event.user_id < 1 or event.user_id == nil or event.user == nil 
      raise "#{event.class.to_s}: user_id = #{event.user_id} is invalid"
    else
      true
    end    
  end

  # split a phrase into array
  #   trim extra spaces on both sides for every element
  #
  def split_phrase(phrase, delimeter = ' ')
    phrase.blank? ? [""] : phrase.split(delimeter).collect(&:strip)
  end
  
  # difference between datetime values in days, hours, minutes, seconds
  # returns an array of [days, hours, minutes, seconds]
  def distance_of_time_as_array( dt_1, dt_2)
    difference = ((dt_1 > dt_2) ? (dt_1 - dt_2) : (dt_2 - dt_1))

    seconds    = difference % 60
    difference = (difference - seconds) / 60
    minutes    =  difference % 60
    difference = (difference - minutes) / 60
    hours      =  difference % 24
    difference = (difference - hours)   / 24
    days       =  difference % 7
  
    return [days, hours, minutes, seconds]
  end

end
