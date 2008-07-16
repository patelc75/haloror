class Panic < DeviceAlert
  def priority
    return IMMEDIATE
  end
  
  def self.node_name
    return :panic
  end
  def to_s
    "#{user.name} panicked at #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def email_body
    "Hello,\nWe detected that #{user.name} pressed the panic button on #{UtilityHelper.format_datetime_readable(timestamp, user)}" +
      "\n\nThe Halo server received the event #{UtilityHelper.format_datetime_readable(Time.now, user)} \n\n" +
      "Sincerely, Halo Staff"
  end
end
