class CriticalMailer < ActionMailer::ARMailer
  include UtilityHelper
  include ServerInstance

#=============== General Methods for Alerts ======================  
  def non_critical_caregiver_email(model, user=nil)
    user = model.user if user.nil?
    # 
    #  Wed Feb 16 02:16:09 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4174
    setup_message(model.to_s, model.email_body + "\n\nYou received this email because you’re either a myHalo user or a caregiver" + (user.blank? ? '' : " of #{user.name}"))
    setup_caregivers(user, model, :recepients)
    self.priority  = model.priority
  end
  
  def non_critical_caregiver_text(model, user=nil)
    user = model.user if user.nil?    
    setup_message("", model.to_s)      

    setup_caregivers(user, model, :recepients)
    @subject =  ""
    @recipients = @text_recipients
    @from        = "myHalo@HaloMonitoring.com"
    self.priority  = model.priority
  end  
     
  def device_event_operator(event)
    setup_caregivers(event.user, event, :caregiver_info)    
    #@caregiver_info << "EMERGENCY NUM\n" + event.user.profile.emergency_number.name + "\n" + event.user.profile.emergency_number.number if event.user.profile.emergency_number
    user = event.user
     
    account_num, timestamp, body_text = operator_body(event) 
    message_text =  body_text + "\n\n"     
    message_text << "ACCESS" + "\n" + (user.profile.access_information.blank? ? "(No access information)" : user.profile.access_information) + "\n\n"
    message_text << "MEDICAL" + "\n" + (user.profile.allergies.blank? ? "(No medical / allergy information)" : user.profile.allergies) + "\n\n"
    message_text << "PET INFO" + "\n" + (user.profile.pet_information.blank? ? "(No pet information)" : user.profile.pet_information) + "\n\n"
    message_text << "You received this email because you’re a Halo call center agent.\n\n"    
    setup_message(event.to_s_short + " (" + account_num + " " + timestamp + ")", message_text, :use_email_log, :use_host_name_in_from_addr)     
    setup_operators(event, :recepients, :include_phone_call) 
    self.priority  = event.priority
  end
 
  def device_event_operator_text(event)    
    setup_caregivers(event.user, event, :caregiver_info)    

    account_num, timestamp, body_text = operator_body(event) 
    setup_message( account_num  + " " + event.to_s_short, body_text,:use_email_log, :use_host_name_in_from_addr) 
    setup_operators(event, :recepients, :include_phone_call) 
    @recipients = @text_recipients 
    self.priority  = event.priority      
  end
  
  def operator_body(event)
    message_text = ""
    #!event.user.profile.emergency_number.blank? ? (@caregiver_info << '(Emergency) ' + event.user.profile.emergency_number.name + event.user.profile.emergency_number.number)  
    time_zone = Time.zone
    Time.zone = 'Eastern Time (US & Canada)' 
    account_num =  (event.user.profile.account_number.blank? ? "(No acct num)" : "HM" + event.user.profile.account_number)
    if event.respond_to?(:timestamp)
      timestamp =  (event.timestamp.blank? ? "(No timestamp)" : event.timestamp.in_time_zone(Time.zone).to_s) + "\n"     
    elsif event.respond_to?(:created_at)  
      timestamp =  (event.created_at.blank? ? "(No timestamp)" : event.created_at.in_time_zone(Time.zone).to_s) + "\n"           
    end 
    message_text << timestamp
    message_text << @caregiver_info
    message_text << (event.user.address.nil? ? "(No address)" : "Address: " + event.user.address)
    Time.zone = time_zone       
    return account_num, timestamp, message_text   
  end

#=============== Reporting  ======================================    
  def lost_data_daily()
    subject = 'Lost Data Daily Report'
    @body[:period] = 1.week.ago
    @body[:users] = Compliance.report(LostData, @body[:period])    
    setup_daily(subject)
  end

  def device_not_worn_daily()
    subject = 'Device Not Worn Daily Report'
    @body[:period] = 1.week.ago    
    @body[:users] = Compliance.report(StrapNotWorn, @body[:period])
    setup_daily(subject)
  end
  
  def successful_user_logins_daily()
    subject = 'Logins Daily Report'
    @body[:period] = 1.week.ago    
    @body[:users] = Compliance.successful_user_logins(@body[:period])    
    setup_daily(subject)
  end

#================== Other   ======================================    
  def generic_email(to, subject, body, email_log=nil)  
    setup_message(subject, body, email_log)
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
    subject     = "Password Changed"
    setup_message(subject, msg_body)         
  end
  
#============ Safetycare related =================================
  def monitoring_failure(message, event)
    setup_message("call center monitoring failure: #{message}", "The following event triggered, but an error was encountered.\n\nTime: #{Time.now}\n\nError: #{message}\n\nEvent: #{event.to_s}\n\n#{event.inspect}\n\n", :no_email_log)
    @recipients = ["exceptions_critical@halomonitoring.com"]
  end

  def monitoring_heartbeat_failure(message, exception)
    setup_message("safety_care HEARTBEAT failure", "There was a HEARTBEAT failure!\n\nTime: #{Time.now}\n\n  Exception: #{exception}\nError: #{message}\n\n", :no_email_log)
    @recipients = ["exceptions@halomonitoring.com"]
  end
  
  def cancel_call_center_acct(acct_num, name)
    @recipients = Group.safety_care!.email
    subject     = "Cancel Acct #{acct_num} (#{name})"
    #@body[:acct_num] = acct_num
    msg_body = <<-EOF
    Cancel Halo Monitoring Acct# #{acct_num} (#{name})
    EOF
    setup_message(subject, msg_body, :use_email_log, :use_host_name_in_from_addr) 
    @from = "customer_intake@halomonitoring.com"    
  end

#=============== Utility Methods  ================================  
  protected

  #if email_log != :no_email_log, then send BCC to email_log@halomonitoring.com
  #if from_addr != :use_host_name_in_from_addr, then myHalo@halomonitoring.com instead of hostname in from addr
  def setup_message(subject, msg_body, email_log=nil, from_addr=nil)
    @from        = from_addr != :use_host_name_in_from_addr ? "myHalo@halomonitoring.com" : "no-reply@"+ServerInstance.current_host(true)
    @subject     = "[" + ServerInstance.current_host_short_string + "] "
    @subject     += subject unless subject.blank?
    @sent_on     = Time.now
    @bcc         = "email_log@halomonitoring.com" if email_log != :no_email_log
    body msg_body
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
  end

  def recipients_setup(user, alert_option, mode, phone = :no_phone_call)
    @recipients = Array.new if @recipients.nil?
    @text_recipients = Array.new if @text_recipients.nil?
    @caregiver_info = "" if @caregiver_info.nil?
    
    if (alert_option)  #check for null until we figure out a better way to get roles_users_options
      email_bool = alert_option.email_active
      text_msg_bool = alert_option.text_active
      call_bool = alert_option.phone_active

      if (text_msg_bool == true) && (mode == :recepients)
        if !user.profile.cell_phone.blank? && !user.profile.carrier.nil? && (mode == :recepients)
          @text_recipients  << ["#{user.profile.phone_strip(user.profile.cell_phone)}" + "#{user.profile.carrier.domain}"]
        end
      end
      
      if email_bool == true
        if !user.email.blank? && (mode == :recepients)
          @recipients << ["#{user.email}"]
        end
      end
      
      if call_bool == true
        if !user.profile.phone_email.blank? && (mode == :recepients) && (phone == :include_phone_call)
          @recipients  << ["#{user.profile.phone_email}"]
        elsif mode == :caregiver_info
          @caregiver_info += user.contact_info_by_alert_option(alert_option) + "\n" 
        end
      end
    end  
  
    @recipients = @recipients.uniq
  end
  
  #if group = :halo_only, only set up operators for the 'halo' group
  def setup_operators( event, mode, phone = :no_phone_call, group = :all)
    groups = ( (group == :halo_only) ? [Group.find_by_name('halo')] : event.user.is_halouser_for_what )

    operators = User.active_operators.select {|e| e.is_operator_of_any?( groups) }
    
    operators.each do |operator|
      recipients_setup( operator, operator.alert_option_by_type_operator(operator,event), mode, phone)
    end
  end
  
  def daily_recipients
    return ["reports@halomonitoring.com"]  
  end

  def setup_daily(subject)
    @recipients = daily_recipients
    @from        = "no-reply@"+ServerInstance.current_host(true)
    @subject     = "[" + ServerInstance.current_host_short_string + "] #{subject}"
    @sent_on     = Time.now
  end
  
  def set_hostnames
    @primary_host = ServerInstance.current_host
    if ServerInstance.in_hostname?('crit2')
      @primary_host = @primary_host.gsub('crit2', 'crit1')
    end
    @secondary_host = @primary_host.gsub('crit1', 'crit2')
  end

#=============== Deprecated  ===================================  
  def device_event_admin_email(event)
    setup_caregivers(event.user, event, :recepients)
    setup_operators(event, :recepients, :include_phone_call, :halo_only) 
    setup_message(event.to_s, "It has been #{GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT / 60} minutes and we have detected that the GW Alarm button has not been pushed for #{event.user.name} #{event.event.event_type} on #{event.timestamp}")
    self.priority = Priority::IMMEDIATE
  end
end

