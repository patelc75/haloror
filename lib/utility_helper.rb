module UtilityHelper
  include ServerInstance
  
  def self.format_datetime_flex(datetime,user)
    #return datetime if !datetime.respond_to?(:strftime)
    
    # Any interaction between the server and flex should
    # pass information back and forth as UTC.
    # I disabled this TZ translation.  -Neal 9/30/08
#    if user and user.profile and user.profile.time_zone
#      tz = user.profile.tz
#    else
#      tz = TZInfo::Timezone.get('America/Chicago')
#    end
#    datetime = tz.utc_to_local(datetime) 
    
    return datetime.strftime("%a %b %d %H:%M:%S %Z %Y")
  end
  
  def self.format_datetime(datetime,user)
    #lookup = {-7 => 'PST', -6 => 'MST', -5 => 'CST', -4 => 'EST'}
    original_datetime = datetime
    return datetime if !datetime.respond_to?(:strftime)
    
    if user and user.profile and user.profile.time_zone
      tz = user.profile.tz
    else
      tz = TZInfo::Timezone.get('America/Chicago')
    end
    datetime = tz.utc_to_local(datetime) 
    #datetime.strftime("%m-%d-%Y %H:%M")
    #datetime.strftime("%a %b %d %H:%M:%S %Z %Y")
    
    newdate = datetime.strftime("%a %b %d %H:%M:%S")
    offset = datetime.hour - original_datetime.hour
    
    if datetime.day != original_datetime.day  
      offset = offset - 24
    end
    
    return "#{newdate} #{offset} #{datetime.strftime("%Y")}"
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
  
  def self.safe_send_email(message, to)
    begin
      email = Email.new(:mail => "#{ServerInstance.current_host()}.Message = #{message}", 
                        :to => to, 
                        :from => 'no-reply@halomonitoring.com', 
                        :priority => 100)
      ar_sendmail = ActionMailer::ARSendmail.new
      ar_sendmail.deliver([email])
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("Exception in UtilityHelper.self.safe_send_email #{e}")
    rescue
      RAILS_DEFAULT_LOGGER.warn("Exception in UtilityHelper.self.safe_send_email")
    end
  end

  def self.format_datetime_readable(datetime,user)
    format_datetime(datetime,user).to_time.strftime("%I:%M%p on %a %m/%d/%Y") if datetime != nil
  end
  
  def get_timezone_offset(user)
    now = Time.now()
    
    if user and user.profile and user.profile.time_zone
      tz = user.profile.tz
    else
      tz = TZInfo::Timezone.get('America/Chicago')
    end
    datetime = tz.utc_to_local(now)
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
end
