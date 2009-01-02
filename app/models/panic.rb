class Panic < DeviceAlert
  set_table_name('panics')
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
      "\n\nA Halo operator will be handling the event immediately.\n\n" +
      "Sincerely, Halo Staff"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
