class UserObserver < ActiveRecord::Observer
  def after_create(user)
    # WARNING: DEPRECATED :is_new_halouser, :is_new_user, :is_new_subscriber, :is_new_caregiver
    # CHANGED: we can now use user_intake object to create users and profiles
    # example:
    #  profile_attributes = Profile.new({...}).attributes
    #  user_attributes = User.new({..., :profile_attributes => profile_attributes}).attributes
    #  user_intake = UserIntake.new(:senior_attributes => user_attributes) # includes profile attributes
    #    or
    #  user_intake = UserIntake.new(:senior_attributes => User.new({:email => ..., :profile_attributes => Profile.new({...}).attributes}).attributes)
    #
    # user must have 'halouser' role
    # after_create is triggered only when a new user is created
    #
    # apply roles for this user if any in :roles attr_accessor
    user.lazy_roles.each {|key, value| user.send("is_#{key}_of".to_sym, value) } unless user.lazy_roles.blank? || user.blank?
  end

  def after_save(user)
    #
    # now trigger the email for installation/notification
    # business logic changed to send emails on any successful "submit"
    # "submit" vs "save" is identified here by skip_validation attribute
    unless user.skip_validation # if use was just "saved" do not trigger emails
      if user.is_halouser? && !user.email.blank? # WARNING: DEPRECATED user[:is_new_halouser] == true
        UserMailer.deliver_signup_installation(user,user)
      else
        UserMailer.deliver_signup_notification(user) unless user.is_caregiver? || user.is_subscriber? # (user[:is_caregiver] or user[:is_new_subscriber])
      end
      #
      # activation email gets delivered anyways
      UserMailer.deliver_activation(user) if user.recently_activated?
    end
  end
end
