class CriticalMailer < ActionMailer::ARMailer
  include UtilityHelper
  #  def device_unavailable_alert_notification(alert, user)
  ##    setup_email(user, alert)
  ##    @subject    += "Device Unavailable for User #{user.id}"
  ##    self.priority = alert.priority
  #    body :alert_created_at => alert.created_at,
  #      :login     => user.login,
  #      :user_id   => user.id,
  #      :alert_id => alert.id,
  #      :device_id => alert.device_id
  #  end
  #
  #  # alert: DeviceAvailableAlert
  #  def device_available_alert_notification(alert, user)
  #    setup_email(user, alert)
  #    @subject    += "Device Available for User #{user.id}"
  #    self.priority = alert.priority
  #    body :alert_created_at => alert.created_at,
  #      :login     => user.login,
  #      :user_id   => user.id,
  #      :alert_id => alert.id,
  #      :device_id => alert.device_id
  #  end
  #  
  #  def gateway_online_notification(alert, user)
  #    device = alert.device
  #    setup_email(user, alert)
  #    @subject    += "Gateway #{alert.device_id} Is Back Online"
  #    self.priority = alert.priority
  #    body :alert_created_at => alert.created_at,
  #      :login     => user.login,
  #      :user_id   => user.id,
  #      :device_id => device.id
  #  end
  #
  #  def gateway_offline_notification(outage, user)
  #    device = outage.device
  #    setup_email(user, outage)
  #    @subject    += "Gateway Offline for Device #{outage.device_id}"
  #    self.priority = outage.priority    
  #    body :outage_created_at => outage.created_at,
  #      :login     => user.login,
  #      :user_id   => user.id,
  #      :device_id => device.id
  #  end
  #
  #  def strap_on_notification(alert, user)
  #    device = alert.device
  #    setup_email(user, alert)
  #    @subject    += "Strap On for Device #{alert.device_id}"
  #    self.priority = alert.priority    
  #    body :alert_created_at => alert.created_at,
  #      :login     => user.login,
  #      :user_id   => user.id,
  #      :device_id => device.id
  #  end
  #
  #  def strap_off_notification(alert, user)
  #    device = alert.device
  #    setup_email(user, alert)
  #    @subject    += "Strap Off for Device #{alert.device_id}"
  #    self.priority = alert.priority    
  #    body :alert_created_at => alert.created_at,
  #      :login     => user.login,
  #      :user_id   => user.id,
  #      :device_id => device.id
  #  end
  def background_task_notification(alert, user)
    body = "Alert ID: #{alert.id}\n" +
      "User #{user.name} (#{user.id})\n" +
      "Device ID: #{alert.device.id}\n" +
      "Detected at #{alert.created_at}"

    setup_message(alert.to_s, body)
    setup_caregivers(user, alert)
    setup_operators(alert)
    self.priority = alert.priority
  end
  
  def device_event_notification(event)
    setup_message(event.to_s, event.email_body)
    setup_caregivers(event.user, event)
    setup_operators(event)
    self.priority  = event.priority
  end

  def call_center_notification(event_action)
    setup_message(event_action.to_s, event_action.email_body)
    setup_operators(event_action.event.event)
    setup_caregivers(event_action.event.user, alert) if(event_action.description == "resolved")
    self.priority  = event_action.priority
  end
  
  def test_email(to, subject, body) 
    setup_message(subject, body)
    @recipients  << to
    self.priority = Priority::IMMEDIATE
  end
  
  protected
  #  def setup_email(user, alert)
  #    setup_message()
  #    setup_caregivers(user, alert)
  #    @body[:user] = user  #sends params to body
  #  end
  
  def setup_message(subject, msg_body)
    @from        = "no-reply@halomonitoring.com"
    @subject     = "[HALO] "
    @subject     += subject unless subject.blank?
    @sent_on     = Time.now
    @recipients = Array.new
    body msg_body
  end
      
  def setup_caregivers(user, alert)
    recipients_setup(user, user.alert_option(alert))
    user.caregivers.each do |caregiver|
      recipients_setup(caregiver, user.alert_option_by_type(caregiver, alert))  
    end
  end
  
  def setup_operators(event)
    operators = User.operators
    if operators
      operators.each do |operator|
        recipients_setup(operator, operator.alert_option_by_type_operator(operator,event))
      end
    end
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
end
	
