class CriticalMailer < ActionMailer::ARMailer
  
  def device_alert_notification(device_alert)
    if(device_alert.device == nil)
      raise "#{device_alert.class.to_s}: device_id = #{device_alert.device_id} does not exist"
    else
      setup_email(device_alert.user)
    end
    description = camelcase_to_spaced(device_alert.class.to_s)
    @subject    += "#{description} event"
    self.priority = device_alert.priority
    body :alert_type => description, 
      :timestamp => device_alert.timestamp,
      :login     => device_alert.user.login,
      :user_id   => device_alert.user.id
  end

  # alert: DeviceUnavailableAlert
  def device_unavailable_alert_notification(alert, user)
    setup_email(user)
    @subject    += "Device Unavailable for User #{user.id}"
    self.priority = alert.priority
    body :alert_created_at => alert.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :alert_id => alert.id
  end

  # alert: DeviceAvailableAlert
  def device_available_alert_notification(alert, user)
    setup_email(user)
    @subject    += "Device Available for User #{user.id}"
    self.priority = alert.priority
    body :alert_created_at => alert.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :alert_id => alert.id
  end
  
  def gateway_online_notification(alert, user)
    device = alert.device
    setup_email(user)
    @subject    += "Gateway #{alert.device_id} Is Back Online"
    self.priority = alert.priority
    body :alert_created_at => alert.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :device_id => device.id
  end

  def gateway_offline_notification(outage, user)
    device = outage.device
    setup_email(user)
    @subject    += "Gateway Offline for Device #{outage.device_id}"
    self.priority = outage.priority    
    body :outage_created_at => outage.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :device_id => device.id
  end

  def fall_notification(fall)
    setup_email(fall.user)
    @subject    += 'Merle fell'
    self.priority = fall.priority
    #@body[:url]  = "Merle fell on #{Time.now}"
    body :timestamp => fall.timestamp
  end
  
  def panic_notification(panic)
    @panic = panic
    setup_email(panic.user)
    @subject    += 'Merle panicked'
    self.priority = panic.priority
    #@body[:url]  = "Merle panicked on #{Time.now}"
    body :timestamp => panic.timestamp
  end
  
  protected
  def setup_email(user)
    @recipients = Array.new
    
    if profile = user.profile
      if profile.cell_phone != nil and profile.cell_phone != "" and profile.carrier != nil
        @recipients << ["#{profile.cell_phone}" + "#{profile.carrier.domain}"]
      end
    end
  
    if user.email != nil and user.email != ""
      @recipients << ["#{user.email}"]
    end
  
    user.has_caregivers.each do |caregiver|
      opts = caregiver.roles_users_option
      if (opts)  #check for null until we figure out a better way to get roles_users_options
        em_bool = opts.email_active
        tm_bool = opts.text_active
   
        if tm_bool == true
          if caregiver.profile.cell_phone != nil and caregiver.profile.cell_phone != ""
            @recipients  << ["#{caregiver.profile.cell_phone}" + "#{caregiver.profile.carrier.domain}"] 
          end
        end
    
        if em_bool == true
          if caregiver.email != nil and caregiver.email != ""
            @recipients  << ["#{caregiver.email}"] 
          end
        end
      end
    end
  
    @from        = "no-reply@myhalomonitor.com"
    @subject     = "[HALO] "
    @sent_on     = Time.now
    @body[:user] = user  #sends params to body
  end
  
  def camelcase_to_spaced(word)
    word.gsub(/([A-Z])/, " \\1")
  end
end
	
