class UserMailer < ActionMailer::ARMailer
  include ServerInstance
  
  def signup_installation(recipient,senior=:exclude_senior_info)
    setup_email(recipient)
    @subject    += 'Please read before your installation'
    @body[:host] = "http://#{ServerInstance.current_host}"
    if senior == :exclude_senior_info
      @body[:name] = nil
    elsif senior.is_a?(User)
      @body[:url]  = "http://#{ServerInstance.current_host}/activate/#{senior.activation_code}"
      @body[:name] = senior.name
    else
      raise "senior must be a User object or :exclude_senior_info"
    end
  end
  
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new myHalo account'
  
    #@body[:url]  = "http://67-207-146-58.slicehost.net/activate/#{user.activation_code}"
    #@body[:url]  = "http://localhost:3000/activate/#{user.activation_code}"
    @body[:url]  = "http://#{ServerInstance.current_host}/activate/#{user.activation_code}"
    @body[:name] = user.name
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{ServerInstance.current_host}/login"
    @body[:user] = user
  end
  
  def caregiver_email(caregiver, user)
    setup_email(caregiver)
    @subject += "#{user.name} wants you to be their caregiver"
    body <<-EOF
      You have been invited to be a caregiver for #{user.name}.
      
       Please click here to activate the account and configure your alerts:  http://#{ServerInstance.current_host}/activate/#{caregiver.activation_code}?senior=#{user.id}
    EOF
  end
  
  def kit_serial_number_register(user,kit_serial_number,current_user)
  	setup_email(user)
  	@recipients  = "senior_signup@halomonitoring.com"
  	@subject += "New myHalo User Signed Up"
  	@body[:kit_serial_number] = kit_serial_number
  	@body[:current_user] = current_user
  	groups = ""
  	user.is_halouser_for_what.each { |group| groups+= group.name + " " }
  	@body[:groups] = groups
  	@body[:user] = user
  end
  
  def subscriber_email(subscriber)
  	setup_email(subscriber)
  	@bcc = "senior_signup@halomonitoring.com"
  	@subject += "myHalo Receipt"
  	subscription = Subscription.find_by_subscriber_user_id(subscriber.id)
  	@body[:subscription] = subscription
  	@body[:halouser] = subscriber.is_subscriber_for_what.first.name
  	@body[:user] = subscriber
  end
  
  def order_summary(order)
    setup_email(order.bill_email)
    @bcc = 'senior_signup@halomonitoring.com'
    @subject += "Order Summary"
    @body[:order] = order
  end
  
  protected
  
  def setup_email(user_obj_or_email_addr)
    if user_obj_or_email_addr.is_a?(User)
      @recipients  = "#{user_obj_or_email_addr.email}"
    elsif user_obj_or_email_addr.is_a?(String)
      @recipients  = user_obj_or_email_addr
    else
      raise "user_obj_or_email_addr must be a User object or email string"
    end
    @from        = "no-reply@halomonitoring.com"
    @subject     = "[" + ServerInstance.current_host_short_string + "] "
    @bcc         = "emaillog@halomonitoring.com"
    @sent_on     = Time.now
    self.priority = Priority::IMMEDIATE
  end
end