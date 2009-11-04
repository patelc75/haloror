class UserMailer < ActionMailer::ARMailer
  include ServerInstance
  
  def signup_notification_halouser(user)
    setup_email(user)
    @subject    += 'Please read before your installation'
  
    #@body[:url]  = "http://67-207-146-58.slicehost.net/activate/#{user.activation_code}"
    #@body[:url]  = "http://localhost:3000/activate/#{user.activation_code}"
    @body[:host] = "http://#{ServerInstance.current_host}"
    @body[:url]  = "http://#{ServerInstance.current_host}/activate/#{user.activation_code}"
  end
  
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new myHalo account'
  
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
      You have been invited to be a caregiver for #{user.name}.
      
       Please click here to activate the account and configure your alerts:  http://#{ServerInstance.current_host}/activate/#{caregiver.activation_code}?senior=#{user.id}
    EOF
  end
  
  def kit_serial_number_register(user,kit)
  	setup_email(user)
  	@recipients  = "senior_signup@halomonitoring.com"
  	@subject += "New myHalo User Signed Up"
  	@body[:kit] = kit
  end
  def subscriber_email(subscriber)
  	setup_email(subscriber)
  	@bcc = "senior_signup@halomonitoring.com"
  	@subject += "myHalo Receipt"
  	subscription = Subscription.find_by_subscriber_user_id(subscriber.id)
  	@body[:subscription] = subscription
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


def caregiver_email(caregiver, user)
  setup_email(caregiver)
  @subject += "#{user.name} wants you to be their caregiver"
  body <<-EOF
    You have been invited to be a caregiver for #{user.name}.
    
     Please click here to activate the account and configure your alerts:  http://#{ServerInstance.current_host}/activate/#{caregiver.activation_code}?senior=#{user.id}
  EOF
end