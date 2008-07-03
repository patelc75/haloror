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

  def strap_on_notification(alert, user)
    device = alert.device
    setup_email(user, alert)
    @subject    += "Strap On for Device #{alert.device_id}"
    self.priority = alert.priority    
    body :alert_created_at => alert.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :device_id => device.id
  end

  def strap_off_notification(alert, user)
    device = alert.device
    setup_email(user, alert)
    @subject    += "Strap Off for Device #{alert.device_id}"
    self.priority = alert.priority    
    body :alert_created_at => alert.created_at,
      :login     => user.login,
      :user_id   => user.id,
      :device_id => device.id
  end

  def fall_notification(fall)
    setup_email(fall.user, fall)
    operators = User.operators
    if operators
      operators.each do |operator|
        recipients_setup(operator, operator.alert_option_by_type_operator(operator,fall))
      end
    end
    if(fall.user.profile)
      @subject    += "#{fall.user.profile.first_name} #{fall.user.profile.last_name} fell"
    else
      @subject    += "#{fall.user.login} fell"
    end
    
    self.priority = fall.priority

    body :timestamp => fall.timestamp,
      :user => fall.user
  end
  
  def panic_notification(panic)
    @panic = panic
    setup_email(panic.user, panic)
    operators = User.operators
    if operators
      operators.each do |operator|
        recipients_setup(operator, operator.alert_option_by_type_operator(operator,panic))
      end
    end
    if(panic.user.profile)
      @subject    += "#{panic.user.profile.first_name} #{panic.user.profile.last_name} panicked"
    else
      @subject    += "#{panic.user.login} panicked"
    end
    self.priority = panic.priority

    body :timestamp => panic.timestamp,
      :user => panic.user
  end

  def test_email(to, subject, body)
    @from        = "no-reply@halomonitoring.com"
    @subject     = "[HALO] " + subject
    @sent_on     = Time.now
    @body[:body_text] = body  #sends params to body
    @recipients  = to
    self.priority = Priority::IMMEDIATE
  end
  
  protected
  def setup_email(user, alert)
    @recipients = Array.new
    
    # if profile = user.profile
    #       if profile.cell_phone != nil and profile.cell_phone != "" and   profile.carrier != nil
    #         @recipients << ["#{profile.cell_phone}" + "#{profile.carrier.domain}"]
    #       end
    #     end
    #   
    #     if user.email != nil and user.email != ""
    #       @recipients << ["#{user.email}"]
    #     end
    
    recipients_setup(user, user.alert_option(alert))
    user.caregivers.each do |caregiver|
      recipients_setup(caregiver, user.alert_option_by_type(caregiver, alert))  
    end  
    @from        = "no-reply@halomonitoring.com"
    @subject     = "[HALO] "
    @sent_on     = Time.now
    @body[:user] = user  #sends params to body
  end
  
  def recipients_setup(user, alert_option)
    if (alert_option)  #check for null until we figure out a better way to get roles_users_options
      email_bool = alert_option.email_active
      text_msg_bool = alert_option.text_active
      iping_call_bool = alert_option.phone_active
      
      if text_msg_bool == true
        if !user.profile.cell_phone.blank?
          @recipients  << ["#{user.profile.cell_phone}" + "#{user.profile.carrier.domain}"]
        end
      end
      if email_bool == true
        if !user.email.blank?
          @recipients  << ["#{user.email}"]
        end
      end
      
      if iping_call_bool == true
        if !user.profile.phone_email.blank?
          @recipients  << ["#{user.profile.phone_email}"]
        end
      end
    end  
  end
  
  def camelcase_to_spaced(word)
    word.gsub(/([A-Z])/, " \\1")
  end
end
	
