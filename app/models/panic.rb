class Panic < CriticalDeviceAlert
  set_table_name('panics')

  def to_s
    "#{user.name} panicked at #{UtilityHelper.format_datetime(timestamp, user)}"
  end
  
  def email_body
    "Hello,\nWe detected that #{user.name} pressed the panic button on #{UtilityHelper.format_datetime(timestamp, user)}" +
      "\n\nA Halo operator will be handling the event immediately.\n\n" +
      "Sincerely, Halo Staff"
  end
end