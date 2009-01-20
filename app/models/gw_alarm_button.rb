class GwAlarmButton < DeviceAlert
  set_table_name "gw_alarm_buttons"

  def priority
    return IMMEDIATE
  end
  
  def to_s
    "Gateway Alarm button pressed on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  #for rspec
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
