class CriticalMailer < ActionMailer::ARMailer
  include UtilityHelper
    
  def background_task_notification(alert, user)
    body = "User #{user.name} (#{user.id})\n" +
      "Detected at #{UtilityHelper.format_datetime_readable(alert.created_at, user)}\n" +
      "Device ID: #{alert.device.id}  Alert ID: #{alert.id}\n"
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
    setup_caregivers(event_action.event.user, event_action.event.event) if(event_action.description == "resolved")
    self.priority  = event_action.priority
  end
  
  def test_email(to, subject, body) 
    setup_message(subject, body)
    @recipients  << to
    self.priority = Priority::IMMEDIATE
  end
  
  protected

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
	
