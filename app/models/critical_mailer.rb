class CriticalMailer < ActionMailer::Base
  def fall_notification(user)
    setup_email(user)
    @subject    += 'Merle fell'
    @body[:url]  = "Merle fell"
  end
  
  def panic_notification(user)
    setup_email(user)
    @subject    += 'Merle panicked'
    @body[:url]  = "Merle panicked"
  end
  
  protected
    def setup_email(user)
      #@recipients  = "#{user.email}"
	  #@recipients  = ["2567974668@tmomail.net", "chirag@chirag.name"]
	  @recipients  = ["chirag@chirag.name"]
      @from        = "chirag@haloresearch.net"
      @subject     = ""
      @sent_on     = Time.now
      @body[:user] = user  #sends params to body
    end
end
