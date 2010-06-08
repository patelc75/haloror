class Panic < CriticalDeviceAlert
  set_table_name('panics')

  # trigger
  # we just need it for this event. Not critical_device_alert.rb super class
  def after_save
    if (user = User.find(user_id))
      user.last_panic_id = id
      user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
    end
  end

  def to_s
    "#{user.name} panicked at #{UtilityHelper.format_datetime(timestamp, user)}"
  end
  
  def email_body
    "Hello,\nWe detected that #{user.name} pressed the panic button on #{UtilityHelper.format_datetime(timestamp, user)}" +
      "\n\nA Halo operator will be handling the event immediately.\n\n" +
      "Sincerely, Halo Staff"
  end
end