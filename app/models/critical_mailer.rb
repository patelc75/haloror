class CriticalMailer < ActionMailer::ARMailer
  include UtilityHelper
    
  def background_task_notification(alert, user)
    body = "User #{user.name} (#{user.id})\n" +
      "Detected at #{UtilityHelper.format_datetime_readable(alert.created_at, user)}\n" +
      "Device ID: #{alert.device.id}  Alert ID: #{alert.id}\n"
    setup_message(alert.to_s, body)
    setup_caregivers(user, alert, :recepients)
    self.priority = alert.priority
  end
  
  def device_event_caregiver(event)
    setup_message(event.to_s, event.email_body)
    setup_caregivers(event.user, event, :recepients)
    self.priority  = event.priority
  end
    
  def device_event_operator(event)
    setup_caregivers(event.user, event, :caregiver_info)
    setup_message(event.to_s, @caregiver_info)
    setup_operators(event, :recepients, :include_phone_call) 
    self.priority  = event.priority
  end

  def call_center_caregiver(event_action)
    setup_message(event_action.to_s, event_action.email_body)
    setup_caregivers(event_action.event.user, event_action.event.event, :recepients)
    self.priority  = event_action.priority
  end
  
  def call_center_operator(event_action)    
    setup_message(event_action.to_s, event_action.email_body + event_action.event.notes_string)
    setup_operators(event_action.event.event, :recepients)
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
    body msg_body
  end
      
  def setup_caregivers(user, alert, mode)
    self_alert = user.alert_option(alert)
    recipients_setup(user, self_alert, mode)
    if mode == :caregiver_info and self_alert == nil
      @caregiver_info = "(U) " + user.contact_info() + "\n"
    end
    user.active_caregivers.each do |caregiver|
      recipients_setup(caregiver, user.alert_option_by_type(caregiver, alert), mode)  
    end
  end
  
  def setup_operators(event, mode, phone = :no_phone_call)
    operators = User.operators
    if operators
      operators.each do |operator|
        recipients_setup(operator, operator.alert_option_by_type_operator(operator,event), mode, phone)
      end
    end
  end

  
  def recipients_setup(user, alert_option, mode, phone = :no_phone_call)
    @recipients = Array.new if @recipients.nil?
    
    if (alert_option)  #check for null until we figure out a better way to get roles_users_options
      email_bool = alert_option.email_active
      text_msg_bool = alert_option.text_active
      call_bool = alert_option.phone_active
      
      if text_msg_bool == true and mode == :recepients
        if !user.profile.cell_phone.blank? and mode == :recepients
          @recipients  << ["#{user.profile.cell_phone}" + "#{user.profile.carrier.domain}"]
        end
      end
      
      if email_bool == true
        if !user.email.blank? and mode == :recepients
          @recipients << ["#{user.email}"]
        end
      end
      
      if call_bool == true
        if !user.profile.phone_email.blank? and mode == :recepients and phone == :include_phone_call
          @recipients  << ["#{user.profile.phone_email}"]
        elsif mode == :caregiver_info
          @caregiver_info += user.contact_info_by_alert_option(alert_option) + "\n" 
        end
      end
    end  
  end
end
	
