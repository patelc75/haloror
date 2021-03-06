class GwAlarmButtonTimeout < DeviceAlert
  set_table_name "gw_alarm_button_timeouts"

  belongs_to :event, :polymorphic => true
  
  def priority
    return IMMEDIATE
  end
  
  def to_s
    "Gateway Alarm button has NOT been pushed for #{GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT / 60} minutes for #{user.name}'s #{event.class.class_name} on #{UtilityHelper.format_datetime(timestamp, user)}"    	
  end
  
  def email_body
    "It has been #{GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT / 60} minutes and we have detected that the Gateway Alarm button has not been pushed for #{user.name}'s #{event.class.class_name} on #{UtilityHelper.format_datetime(timestamp, user)}\n\n" +
      "- Halo Staff"
  end

  #for rspec
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
