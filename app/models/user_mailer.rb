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
  
  def caregiver_email(caregiver, user)
    setup_email(caregiver)
    @subject += "#{user.name} wants you to be their caregiver"
    body <<-EOF
      #{user.name} wants you to be their caregiver.
      
      Please complete the signup process at:  http://#{ServerInstance.current_host}/activate/caregiver/#{caregiver.activation_code}
    EOF
        
  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "no-reply@halomonitoring.com"
    @subject     = "[" + ServerInstance.current_host_short_string + "] "
    @sent_on     = Time.now
    @body[:user] = user
    self.priority = Priority::IMMEDIATE
  end
end
