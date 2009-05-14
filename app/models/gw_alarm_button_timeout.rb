class GwAlarmButtonTimeout < DeviceAlert
  set_table_name "gw_alarm_button_timeouts"

  def priority
    return IMMEDIATE
  end
  
  def to_s
    "It has been #{GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT / 60} minutes and we have detected that the Gateway Alarm button has not been pushed for #{user.name}'s #{event.event_type} on #{event.timestamp}"
  end

  #for rspec
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
