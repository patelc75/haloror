class Fall < DeviceAlert
  set_table_name("falls")
  def priority
    return IMMEDIATE
  end
  
  def to_s
    "#{user.name}(#{user.id}) fell at #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def email_body
    "Hello,\nWe detected that #{to_s}\n\n" +
    "The Halo server received the event #{UtilityHelper.format_datetime_readable(Time.now, user)} \n\n"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    if random
      model.magnitude = 60
    else
      model.magnitude = rand(60)
    end
    return model    
  end
end
