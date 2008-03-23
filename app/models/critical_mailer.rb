class CriticalMailer < ActionMailer::Base
  
  def device_alert_notification(device_alert)
    setup_email(device_alert.device.user)
    description = camelcase_to_spaced(device_alert.class.to_s)
    @subject    += "#{description} event"
    body :alert_type => description, 
      :timestamp => device_alert.timestamp
  end

  # alert: DeviceUnavailableAlert
  def device_unavailable_alert_notification(alert)
    setup_email(alert.user)
    @subject    += "Device Unavailable for User #{alert.user_id}"
    body :alert_created_at => alert.created_at,
      :login     => alert.user.login,
      :user_id   => alert.user.id,
      :alert_id => alert.id
  end
  
  def outage_alert_notification(outage)
    device = outage.device
    setup_email(outage.device.user)
    @subject    += "Outage for Device #{outage.device_id}"
    body :outage_created_at => outage.created_at,
      :login     => device.user.login,
      :user_id   => device.user.id,
      :device_id => device.id
  end

  def fall_notification(fall)
    setup_email(fall.user)
    @subject    += 'Merle fell'
    #@body[:url]  = "Merle fell on #{Time.now}"
    body :timestamp => fall.timestamp
  end
  
  def panic_notification(panic)
    @panic = panic
    setup_email(panic.user)
    @subject    += 'Merle panicked'
    #@body[:url]  = "Merle panicked on #{Time.now}"
    body :timestamp => panic.timestamp
  end
  
  protected
  def setup_email(user)
    @recipients = Array.new
    
    if user.profile.cell_phone != nil and user.profile.cell_phone != "" and user.profile.carrier != nil
      @recipients << ["#{user.profile.cell_phone}" + "#{user.profile.carrier.domain}"]
    end
  
    if user.email != nil and user.email != ""
      @recipients << ["#{user.email}"]
    end
  
    user.has_caregivers.each do |caregiver|
      opts = caregiver.roles_users_option
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
  
    @from        = "no-reply@myhalomonitor.com"
    @subject     = "[HALO] "
    @sent_on     = Time.now
    @body[:user] = user  #sends params to body
  end
  
  def camelcase_to_spaced(word)
    word.gsub(/([A-Z])/, " \\1")
  end
end
	
