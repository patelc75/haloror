class DeviceAlertObserver < ActiveRecord::Observer
  observe BatteryPlugged, BatteryUnplugged, BatteryCritical, BatteryChargeComplete, StrapFastened, StrapRemoved
  
  def before_save(alert)
    if(alert.device == nil)
      raise "#{device_alert.class.to_s}: device_id = #{device_alert.device_id} does not exist"
    else
      email = CriticalMailer.deliver_device_event_notification(alert)
    end
  end
	
  def after_save(alert)
    Event.create(:user_id => alert.user_id, 
      :event_type => alert.class.to_s, 
      :event_id => alert.id, 
      :timestamp => alert.timestamp
    )
  end
end
