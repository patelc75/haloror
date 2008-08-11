

module UtilityHelper
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
  
  def self.log_message(message) 
    RAILS_DEFAULT_LOGGER.warn(message)
    safe_send_email(message)
  end
  
  def self.safe_send_email(message)
    begin
      email = Email.new(:mail => "#{ServerInstance.current_host()}::Message => #{message}", 
                        :to => 'exceptions_www@halomonitoring.com', 
                        :from => 'no-reply@halomonitoring.com', 
                        :priority => 100)
      ar_sendmail = ActionMailer::ARSendmail.new
      ar_sendmail.deliver([email])
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("Exception in UtilityHelper.self.safe_send_email:: #{e}")
    rescue
      RAILS_DEFAULT_LOGGER.warn("Exception in UtilityHelper.self.safe_send_email::")
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
end
