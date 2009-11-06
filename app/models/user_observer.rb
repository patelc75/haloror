class UserObserver < ActiveRecord::Observer
  def after_create(user)
    if user[:is_new_halouser] == true
      UserMailer.deliver_signup_notification_halouser(user,user)
    else
      UserMailer.deliver_signup_notification(user) unless user[:is_caregiver]
    end
  end

  def after_save(user)
    UserMailer.deliver_activation(user) if user.recently_activated?
  end
end
