class UserObserver < ActiveRecord::Observer
  def after_create(user)
    if user[:is_new_halouser] == true
      UserMailer.deliver_signup_installation(user,user)
    else
      UserMailer.deliver_signup_notification(user) unless (user[:is_caregiver] or user[:is_new_subscriber])
    end
  end

  def after_save(user)
    UserMailer.deliver_activation(user) if user.recently_activated?
  end
end
