class CriticalMailer < ActionMailer::Base
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
    #@recipients  = "#{user.email}"
    #@recipients  = ["2567974668@tmomail.net", "chirag@chirag.name"]
	  
    @recipients  = ["#{critical_event.user.email}","#{critical_event.user.profile.text_email}"]
    @from        = "no-reply@halomonitoring.com"
    @subject     = ""
    @sent_on     = Time.now
    @body[:user] = critical_event.user  #sends params to body
  end
end
	