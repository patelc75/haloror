class UserMailer < ActionMailer::ARMailer
  include ServerInstance

  def update_to_safety_care( user_intake)
    setup_email(Group.safety_care.email) 
    @subject     += "Update #{user_intake.senior.call_center_account}"
    @body[:user_intake] = user_intake
  end
  
  def senior_and_caregiver_details(user)
    setup_email(Group.safety_care.email) 
    @subject     += "#{user.profile.account_number}"
    #content_type "text/html"
    @body[:user] = user
  end
  
  def user_installation_alert(user)
    setup_email("senior_signup@halomonitoring.com")       
    @subject += "#{user.name} installed"
    body        :user => user
  end

  def signup_installation(recipient,senior=:exclude_senior_info)
    setup_email(recipient)
    @subject    += EMAIL_SUBJECT[:installation] # 'Please read before your installation'
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
    @subject    += EMAIL_SUBJECT[:activation] # 'Please activate your new myHalo account'

    #@body[:url]  = "http://67-207-146-58.slicehost.net/activate/#{user.activation_code}"
    #@body[:url]  = "http://localhost:3000/activate/#{user.activation_code}"
    @body[:url]  = "http://#{ServerInstance.current_host}/activate/#{user.activation_code}"
    @body[:name] = user.name
  end

  def activation(user)
    setup_email(user)
    @subject    += EMAIL_SUBJECT[:activated] # 'Your account has been activated!'
    @body[:url]  = "http://#{ServerInstance.current_host}/login"
    @body[:user] = user
  end

  def user_cancelled(user, caregiver)
    setup_email(caregiver)
    @subject += "myHalo account #{user.id} #{user.name} has been cancelled."
    body <<-EOF
    Dear #{caregiver.name},

    This message is the official notice that myHalo account #{user.id} #{user.name} has been cancelled.

    Thanks, 
    myHalo Staff
    EOF
  end
  
  def cancelled_user_attempted_access(user)
    setup_email(user)
    @subject += "Cancelled myHalo account of #{user.name} was used to attempt an access."
    body <<-EOF
    Cancelled myHalo account of #{user.name} was used to attempt an access at #{Time.now}.
    Please do the needful.
    EOF
  end

  def caregiver_invitation(caregiver, user)
    setup_email(caregiver)
    @subject += "#{user.name} wants you to be their caregiver"
    body <<-EOF
    You have been invited to be a caregiver for #{user.name}.

    Please click here to activate the account:  http://#{ServerInstance.current_host}/activate/#{caregiver.activation_code}?senior=#{user.id}
    EOF
  end

  def order_complete(user,kit_serial_number,current_user)
    setup_email(user)
    @recipients  = "senior_signup@halomonitoring.com"
    @subject += EMAIL_SUBJECT[:kit_registered] # "New myHalo User Signed Up"
    @body[:kit_serial_number] = kit_serial_number
    @body[:current_user] = current_user
    groups = ""
    user.is_halouser_for_what.each { |group| groups+= group.name + " " }
    @body[:groups] = groups
    @body[:user] = user
  end

  def order_receipt(subscriber)
    setup_email(subscriber)
    @bcc = "senior_signup@halomonitoring.com"
    @subject += EMAIL_SUBJECT[:receipt] # "myHalo Receipt"
    subscription = Subscription.find_by_subscriber_user_id(subscriber.id)
    @body[:subscription] = subscription
    @body[:halouser] = subscriber.is_subscriber_for_what.first.name
    @body[:user] = subscriber
  end

  def order_summary(order, email_addr, email_log=nil)
    setup_email(email_addr, email_log)
    #
    # https://redmine.corp.halomonitor.com/issues/3419
    @subject += EMAIL_SUBJECT[:order_summary] # "Order Summary"
    @body[:order] = order
  end

  protected

  def setup_email(user_obj_or_email_addr, email_log=nil)
    if user_obj_or_email_addr.nil?
      @recipients  = ""
        
    elsif user_obj_or_email_addr.is_a?(User)
      @recipients  = "#{user_obj_or_email_addr.email}"
    elsif user_obj_or_email_addr.is_a?(String)
      @recipients  = user_obj_or_email_addr
    else
      raise "user_obj_or_email_addr must be a User object or email string"
    end
    @from        = "no-reply@halomonitoring.com"
    @subject     = "[" + ServerInstance.current_host_short_string + "] "
    @bcc         = "email_log@halomonitoring.com" if email_log != :no_email_log
    @sent_on     = Time.now
    #self.priority = Priority::IMMEDIATE  #This was taken out on 10/19/2010 because of fear of SMTP delays. Not sure why this was there in the first place
  end
end