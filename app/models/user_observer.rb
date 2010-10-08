class UserObserver < ActiveRecord::Observer
  #
  # these methods are now in user.rb
  #
  # def after_save(user)
  #   # WARNING: DEPRECATED :is_new_halouser, :is_new_user, :is_new_subscriber, :is_new_caregiver
  #   # CHANGED: we can now use user_intake object to create users and profiles
  #   # example:
  #   #  profile_attributes = Profile.new({...}).attributes
  #   #  user_attributes = User.new({..., :profile_attributes => profile_attributes}).attributes
  #   #  user_intake = UserIntake.new(:senior_attributes => user_attributes) # includes profile attributes
  #   #    or
  #   #  user_intake = UserIntake.new(:senior_attributes => User.new({:email => ..., :profile_attributes => Profile.new({...}).attributes}).attributes)
  #   #
  #   # user must have 'halouser' role
  #   # after_create is triggered only when a new user is created
  #   #
  #   # apply roles for this user if any in :roles attr_accessor
  #   user.lazy_roles.each {|key, value| user.send("is_#{key}_of".to_sym, value) } unless user.lazy_roles.blank? || user.blank?
  # end

  # https://redmine.corp.halomonitor.com/issues/3067
  # CHANGED: Never dispatch emails automatically on save
  #
  # def after_save(user)
  #   #
  #   # now trigger the email for installation/notification
  #   # business logic changed to send emails on any successful "submit"
  #   # "submit" vs "save" is identified here by skip_validation attribute
  #   user.dispatch_emails unless user.skip_validation # if use was just "saved" do not trigger emails
  # end
end
