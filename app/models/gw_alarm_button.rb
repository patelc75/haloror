class GwAlarmButton < DeviceAlert
  set_table_name "gw_alarm_buttons"

  def priority
    return IMMEDIATE
  end
  
  def to_s
    "Gateway Alarm button pressed on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def after_save
    deferred = CallCenterDeferred.find(:all, :conditions => "user_id = #{user_id} AND device_id = #{device_id} AND pending = true")
    if deferred && deferred.size > 0
      deferred.each do |d|
        d.pending = false
        d.save!
      end
    end
  end
  
  #for rspec
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
