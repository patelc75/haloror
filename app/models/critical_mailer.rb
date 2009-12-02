class CriticalMailer < ActionMailer::ARMailer
  include UtilityHelper
  include ServerInstance
  NO_REPLY = "no-reply@halomonitoring.com"

#=============== General Methods for Alerts ======================       
  def device_event_admin(event)
    setup_caregivers(event.user, event, :recepients)
    setup_operators(event, :recepients, :include_phone_call, :halo_only) 
    setup_message(event.to_s, "It has been #{GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT / 60} minutes and we have detected that the GW Alarm button has not been pushed for #{event.user.name} #{event.event.event_type} on #{event.timestamp}")
    self.priority = Priority::IMMEDIATE
  end
  
  def device_event_caregiver(event)
    setup_message(event.to_s, event.email_body + "\n\nYou received this email because you’re a Halo User or caregiver of #{event.user.name}")
    setup_caregivers(event.user, event, :recepients)
    self.priority  = event.priority
  end
  
  def device_event_operator(event)
    # refs #864, New non-wizard email for call center agents
    setup_caregivers(event.user, event, :caregiver_info)
    
    @caregiver_info << "EMERGENCY NUM\n" + event.user.profile.emergency_number.name + "\n" + event.user.profile.emergency_number.number if event.user.profile.emergency_number
    message_text = "You received this email because you’re a Halo call center agent.\n\n#{@caregiver_info}\n\n"
    
    user = event.user
    
    message_text << "ACCOUNT NUM\n%s\n\n" % [user.profile.account_number.blank? ? "(No account number)" : user.profile.account_number]
    message_text << "ADDRESS + LOCK\n%s\n%s\n%s, %s %s\n%s\n\n" % [user.name, user.profile.address, user.profile.city, user.profile.state, user.profile.zipcode, user.profile.access_information.blank? ? "(No access information)" : user.profile.access_information]
    message_text << "MEDICAL\n%s\n\n" % [user.profile.allergies.blank? ? "(No medical / allergy information)" : user.profile.allergies]
    message_text << "PET\n%s\n\n" % [user.profile.pet_information.blank? ? "(No pet information)" : user.profile.pet_information]
    setup_message('URGENT:  ' + event.to_s, message_text)
    setup_operators(event, :recepients, :include_phone_call) 
    #setup_emergency_group(event, :recepients)
    self.priority  = event.priority
  end
 
  def device_event_operator_text(event)
    setup_caregivers(event.user, event, :caregiver_info)
    @caregiver_info << '(Emergency) ' + event.user.profile.emergency_number.name + event.user.profile.emergency_number.number if event.user.profile.emergency_number
    link = get_link_to_call_center_text()

    #setup_message(event.to_s, "Go here: " + link + " If site down, use paper scripts with this info:" + @caregiver_info)
    setup_message(event.to_s, @caregiver_info + "\n" + (event.user.address.nil? ? "(No address)" : event.user.address))
    setup_operators(event, :recepients, :include_phone_call) 
    # setup_emergency_group(event, :recepients)
    @recipients = @text_recipients
    self.priority  = event.priority
  end

#=============== Call Center Operator ======================     
  def call_center_caregiver(event_action)
    setup_message(event_action.to_s, event_action.email_body + "\n\nYou received this email because you’re a Halo User or caregiver of #{event_action.event.user.name}")
    setup_caregivers(event_action.event.user, event_action.event.event, :recepients)
    self.priority  = event_action.priority
  end
  
  def call_center_operator(event_action)
    setup_message(event_action.to_s, event_action.email_body + event_action.event.notes_string + "\n\nYou received this email because you’re an operator.")
    setup_operators(event_action.event.event, :recepients)
    self.priority  = event_action.priority
  end

  def admin_call_log(event, body, recipients)
    @recipients = []
    setup_message("Call Log for #{event.user.name} #{event.event_type} at #{UtilityHelper.format_datetime(event.timestamp, event.user)}", body)
    recipients.each do |admin|
     @recipients << ["#{admin.email}"] 
    end
    @recipients << ["reports@halomonitoring.com"] 
    self.priority = Priority::IMMEDIATE
  end

  #CP 05/13/09 this method is deperecated, use this for from event observer when the call center wizard is being used
  def device_event_operator_wizard(event)
    setup_caregivers(event.user, event, :caregiver_info)
    link = get_link_to_call_center()
    @caregiver_info << '\n\n(Emergency) ' + event.user.profile.emergency_number.name + event.user.profile.emergency_number.number if event.user.profile.emergency_number
    setup_message('URGENT:  ' + event.to_s, "You received this email because you’re an operator.\n\n#{link}\n" + @caregiver_info)
    setup_operators(event, :recepients, :include_phone_call) 
    #setup_emergency_group(event, :recepients)
    self.priority  = event.priority
  end

#=============== Reporting  ========================    
  def lost_data_daily()
    subject = 'Lost Data Daily Report'
    setup_daily(subject)
  end
  
  def device_not_worn_daily()
    subject = 'Device Not Worn Daily Report'
    setup_daily(subject)
  end
  
  def successful_user_logins_daily()
    subject = 'Logins Daily Report'
    setup_daily(subject)
  end

#================== Other   ========================    
  def test_email(to, subject, body) 
    setup_message(subject, body)
    @recipients = []
    @recipients  << to
    self.priority = Priority::IMMEDIATE
  end
  
  def password_confirmation(user)
    @recipients = [user.email]
    msg_body = <<-EOF
  	Hello #{user.name},

  	This message is to let you know that your password has been successfully changed.

  	Thank You,

  	Halo Staff
  	EOF
    subject     = "[" + ServerInstance.current_host_short_string + "] Password Changed"
    setup_message(subject, msg_body)
  end

#============ Safetycare Monitoring ================
  def monitoring_failure(message, event)
    setup_message("safety_care monitoring failure: #{message}", "The following event triggered, but an error was encountered.\n\nTime: #{Time.now}\n\nError: #{message}\n\nEvent: #{event.to_s}\n\n#{event.inspect}\n\n")
    @recipients = ["exceptions@halomonitoring.com"]
  end

  def monitoring_heartbeat_failure(message, exception)
    setup_message("safety_care HEARTBEAT failure", "There was a HEARTBEAT failure!\n\nTime: #{Time.now}\n\n  Exception: #{exception}\nError: #{message}\n\n")
    @recipients = ["exceptions@halomonitoring.com"]
  end

  def background_task_notification(alert, user)
    body = "User #{user.name} (#{user.id})\n" +
      "Detected at #{UtilityHelper.format_datetime(alert.created_at, user)}\n" +
      "Device ID: #{alert.device.id}  Alert ID: #{alert.id}\n"
    setup_message(alert.to_s, body)
    setup_caregivers(user, alert, :recepients)
    self.priority = alert.priority
  end

#=============== Utility Methods  ===================  
  protected
    
  def setup_message(subject, msg_body)
    @from        = "no-reply@#{ServerInstance.current_host}"
    @subject     = "[" + ServerInstance.current_host_short_string + "] "
    @subject     += subject unless subject.blank?
    @sent_on     = Time.now
    body msg_body
  end

  def setup_daily(subject)
    @recipients = daily_recipients
    @from        = NO_REPLY
    @subject     = "[" + ServerInstance.current_host_short_string + "] #{subject}"
    @sent_on     = Time.now
  end

  #if mode = :caregiver_info, then show user AND caregiver info in body
  #if mode = :recepients, then add to @recepients list
  def setup_caregivers(user, alert, mode)
    self_alert = user.alert_option(alert)
    recipients_setup(user, self_alert, mode)
    if mode == :caregiver_info and self_alert == nil
      @caregiver_info = "(U) " + user.contact_info() + "\n"
    end
    user.active_caregivers.each do |caregiver|
      recipients_setup(caregiver, user.alert_option_by_type(caregiver, alert), mode)  
    end
    @recipients = @recipients + @text_recipients
  end
  
  #if group = :halo_only, only set up operators for the 'halo' group
  def setup_operators(event, mode, phone = :no_phone_call, group = :all)
    ops = User.active_operators
    groups = event.user.is_halouser_for_what
    halo_group = Group.find_by_name('halo') if group == :halo_only
    operators = []
    ops.each do |op|
      if (group == :halo_only)
  	    operators << op if op.is_operator_of? halo_group
  	  else
      	operators << op if(op.is_operator_of_any?(groups))
  	  end
    end
    
    if operators
      operators.each do |operator|
        recipients_setup(operator, operator.alert_option_by_type_operator(operator,event), mode, phone)
      end
    end
  end
  
  def setup_emergency_group(event, mode, phone = :no_phone_call)
    users = []
    EMERGENCY_GROUPS.each do |group_name|
      group = Group.find_by_name(group_name)
      roles = Role.find(:all, :conditions => "authorizable_type = 'Group' and authorizable_id = #{group.id}")
      roles.each do |role|
        role.roles_users do |ru|
          users << ru.user if ru.user.is_operator_of? group
        end
      end
    end
    if users
      users.each do |user|
        @recipients << ["#{user.email}"]
      end
    end
  end
  
  def setup_halo_operators()
    @recipients = []
    operators = User.halo_operators()
    if !operators.blank?
      operators.each do |operator|
        @recipients << ["#{operator.email}"] 
      end       
    end
  end
  
  def setup_halo_administrators()
    @recipients = []
    admins = User.halo_administrators()
    if !admins.blank?
      admins.each do |admin|
        @recipients << ["#{admin.email}"] 
      end       
    end
  end
  
  def setup_administrators()
    @recipients = []
    admins = User.administrators()
    if !admins.blank?
      admins.each do |admin|
        @recipients << ["#{admin.email}"] 
      end       
    end
  end
  
  def daily_recipients
    return ["reports@halomonitoring.com"]  
  end
  
  def recipients_setup(user, alert_option, mode, phone = :no_phone_call)
    @recipients = Array.new if @recipients.nil?
    @text_recipients = Array.new if @text_recipients.nil?
    @caregiver_info = "" if @caregiver_info.nil?
    
    if (alert_option)  #check for null until we figure out a better way to get roles_users_options
      email_bool = alert_option.email_active
      text_msg_bool = alert_option.text_active
      call_bool = alert_option.phone_active

      if text_msg_bool == true and mode == :recepients
        if !user.profile.cell_phone.blank? and !user.profile.carrier.nil? and mode == :recepients
          @text_recipients  << ["#{user.profile.phone_strip(user.profile.cell_phone)}" + "#{user.profile.carrier.domain}"]
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
  
    @recipients = @recipients.uniq
  end
  
  def set_hostnames
    @primary_host = ServerInstance.current_host
    if ServerInstance.in_hostname?('crit2')
      @primary_host = @primary_host.gsub('crit2', 'crit1')
    end
    @secondary_host = @primary_host.gsub('crit1', 'crit2')
  end
 
  def get_link_to_call_center_text()
    set_hostnames
	return "https://#{@primary_host}/call_center If the site is not available then try the backup link https://#{@secondary_host}/call_center "
  end
  
  def get_link_to_call_center()
    suffix = "The following contact info is only used for disaster recovery."
	set_hostnames
    if ServerInstance.in_hostname?('crit1') || ServerInstance.in_hostname?('crit2')	  
      return "Please use the following link to accept and handle the event on the the call center overview page.  \nhttps://#{@primary_host}/call_center  \n\nIf the site is not available then try the backup link \nhttps://#{@secondary_host}/call_center \n\n" + suffix 
    else
      return "Please use the following link to accept and handle the event on the the call center overview page.  \nhttps://#{@primary_host}/call_center \n\n" + suffix 
    end
  end

 end
