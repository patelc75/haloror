class CriticalMailer < ActionMailer::ARMailer
  
  def device_alert_notification(device_alert)
    if(device_alert.device == nil)
      raise "#{device_alert.class.to_s}: device_id = #{device_alert.device_id} does not exist"
    else
      setup_email(device_alert.user, device_alert)
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
    setup_email(user, alert)
    @subject    += "Device Unavailable for User #{user.id}"
    self.priority = alert.priority
    body :alert_created_at => alert.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :alert_id => alert.id,
      :device_id => alert.device_id
  end

  # alert: DeviceAvailableAlert
  def device_available_alert_notification(alert, user)
    setup_email(user, alert)
    @subject    += "Device Available for User #{user.id}"
    self.priority = alert.priority
    body :alert_created_at => alert.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :alert_id => alert.id,
      :device_id => alert.device_id
  end
  
  def gateway_online_notification(alert, user)
    device = alert.device
    setup_email(user, alert)
    @subject    += "Gateway #{alert.device_id} Is Back Online"
    self.priority = alert.priority
    body :alert_created_at => alert.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :device_id => device.id
  end

  def gateway_offline_notification(outage, user)
    device = outage.device
    setup_email(user, outage)
    @subject    += "Gateway Offline for Device #{outage.device_id}"
    self.priority = outage.priority    
    body :outage_created_at => outage.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :device_id => device.id
  end

  def fall_notification(fall)
    setup_email(fall.user, fall)
    @subject    += 'Merle fell'
    self.priority = fall.priority
    #@body[:url]  = "Merle fell on #{Time.now}"
    body :timestamp => fall.timestamp
  end
  
  def panic_notification(panic)
    @panic = panic
    setup_email(panic.user, panic)
    @subject    += 'Merle panicked'
    self.priority = panic.priority
    #@body[:url]  = "Merle panicked on #{Time.now}"
    body :timestamp => panic.timestamp
  end
  
  protected
  def setup_email(user, alert)
    @recipients = Array.new
    
    if profile = user.profile
      if profile.cell_phone != nil and profile.cell_phone != "" and   profile.carrier != nil
        @recipients << ["#{profile.cell_phone}" + "#{profile.carrier.domain}"]
      end
    end
  
    if user.email != nil and user.email != ""
      @recipients << ["#{user.email}"]
    end
  
    user.has_caregivers.each do |caregiver|
      #opts = caregiver.roles_users_option
      
      #see load_caregiver.erb for another example of this loop
      user = User.find(caregiver.id)
      roles_user = RolesUser.find(:first, :conditions => "role_id = #{caregiver.roles_user[:role_id]} and user_id = #{user[:id]}")
      
      alert_type_id = AlertType.find(:first, :conditions => "alert_type='#{alert.class.to_s}'").id
      
      if(alert_type_id)
        alert_option = AlertOption.find(:first, :conditions => "alert_type_id=#{alert_type_id} and roles_user_id=#{roles_user.roles_user_id}")

        if (alert_option)  #check for null until we figure out a better way to get roles_users_options
          em_bool = alert_option.email_active
          tm_bool = alert_option.text_active
   
          if tm_bool == true
            if user.profile.cell_phone != nil and user.profile.cell_phone != ""
              @recipients  << ["#{user.profile.cell_phone}" + "#{user.profile.carrier.domain}"] 
            end
          end
    
          if em_bool == true
            if user.email != nil and user.email != ""
              @recipients  << ["#{user.email}"] 
            end
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
	
