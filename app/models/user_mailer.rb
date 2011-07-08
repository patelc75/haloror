class UserMailer < ActionMailer::ARMailer
  include ServerInstance

  def update_to_safety_care( user_intake)
    setup_email(Group.safety_care!.email)
    @from = "customer_intake@halomonitoring.com"     
    @subject     += "Update #{user_intake.senior.call_center_account}"
    @body[:user_intake] = user_intake
  end
  
  def senior_and_caregiver_details(user)
    setup_email(Group.safety_care!.email)
    @from = "customer_intake@halomonitoring.com" 
    @subject     += "HM" + "#{user.profile.account_number}" unless user.profile.blank?
    #content_type "text/html"
    @body[:user] = user
  end
  
  def user_installation_alert( _senior, _email = nil)
    #  Fri Dec 17 21:06:18 IST 2010, ramonrails
    #   * email is now optional. when not supplied, picks user's email
    #   * WARNING: this can send multiple emails if code is not proper
    _email ||= _senior.email
    setup_email( _email) # email can go to anyone given here
    @subject += "#{_senior.name} installed" # user state
    body        :user => _senior # senior details in the email
  end

  def user_panic_warning( _senior, _email = nil)
    _email ||= _senior.email
    setup_email( _email)
    @subject += "Warning: Install attempted for #{_senior.name} without approval from Halo"
    body        :user => _senior
  end

  def user_intake_submitted( _senior, _email = nil)
    _email ||= _senior.email
    setup_email( _email)
    @subject += "User Intake submitted for #{_senior.name}"
    body        :user => _senior
  end
  
  # 
  #  Fri Feb  4 00:03:10 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4146
  def subscription_start_alert( _senior, _email = nil)
    _order = ((!_senior.user_intakes.blank? && !_senior.user_intakes.first.order.blank?) ? _senior.user_intakes.first.order : nil )
    _email ||= _senior.email
    setup_email( _email) # email can go to anyone given here
    @subject += "#{_senior.name}'s prorate & monthly recurring charges have been processed." # user state
    body        :user => _senior, :order => _order, :current_user => Thread.current[:user] # senior details in the email
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

    Thank you,
    Halo Monitoring Customer Support
    1-866-546-2540
    EOF
  end
  
  def cancelled_user_attempted_access(user)
    setup_email(user)
    @subject += "Cancelled myHalo account of #{user.name} was used to attempt an access."
    body <<-EOF
    Cancelled myHalo account of #{user.name} was used to attempt an access at #{Time.now}.
    Please do the needful.
      
    Thank you,
    Halo Monitoring Customer Support
    1-866-546-2540

    EOF
  end

  def caregiver_invitation(caregiver, user)
    setup_email(caregiver)
    @subject += "#{user.name} wants you to be their caregiver"
    body <<-EOF
    You have been invited to be a caregiver for #{user.name}.

    Please click here to activate the account:  http://#{ServerInstance.current_host}/activate/#{caregiver.activation_code}?senior=#{user.id}
    
    Thank you,
    Halo Monitoring Customer Support
    1-866-546-2540
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
    @from        = "myHalo@halomonitoring.com"
    @subject     = "[" + ServerInstance.current_host_short_string + "] "
    @bcc         = "email_log@halomonitoring.com" if email_log != :no_email_log
    @sent_on     = Time.now
    #self.priority = Priority::IMMEDIATE  #This was taken out on 10/19/2010 because of fear of SMTP delays. Not sure why this was there in the first place
  end
end