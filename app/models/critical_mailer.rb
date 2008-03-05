class CriticalMailer < ActionMailer::Base
  
  ## Accepts instance of OutageAlert
  def outage_alert_notification(outage)
    device = outage.device
    setup_email(device)
    @subject    += "Outage for Device #{outage.device_id}"
    body :outage_created_at => outage.created_at,
         :login     => device.user.login,
         :user_id   => device.user.id,
         :device_id => device.id
  end

  def fall_notification(fall)
    setup_email(fall)
    @subject    += 'Merle fell'
    #@body[:url]  = "Merle fell on #{Time.now}"
    body :timestamp => fall.timestamp
  end
  
  def panic_notification(panic)
    @panic = panic
    setup_email(panic)
    @subject    += 'Merle panicked'
    #@body[:url]  = "Merle panicked on #{Time.now
    body :timestamp => panic.timestamp
  end
  
  protected
  def setup_email(critical_event)
  @recipients = Array.new
  @recipients << ["#{critical_event.user.email}","#{critical_event.user.profile.text_email}"]
  critical_event.user.has_caregivers.each do |caregiver|
     opts = caregiver.roles_users_option
     em_bool = opts.email_active
     tm_bool = opts.text_active
      if tm_bool == true
       @recipients  << ["#{caregiver.profile.text_email}"] 
      end
     if em_bool == true
     @recipients  << ["#{caregiver.email}"] 
     end
    end
    @from        = "no-reply@halomonitoring.com"
    @subject     = "[HALO] "
    @sent_on     = Time.now
    @body[:user] = critical_event.user  #sends params to body
end
end
	
