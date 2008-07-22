class UserMailer < ActionMailer::ARMailer
  include ServerInstance
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    #@body[:url]  = "http://67-207-146-58.slicehost.net/activate/#{user.activation_code}"
    #@body[:url]  = "http://localhost:3000/activate/#{user.activation_code}"
	
    @body[:url]  = "http://#{ServerInstance.current_host}/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{ServerInstance.current_host}/login"
  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "no-reply@halomonitoring.com"
    @subject     = "Halo: "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
