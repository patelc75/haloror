class DeviceAlertObserver < ActiveRecord::Observer
  observe Fall, Panic, BatteryPlugged, BatteryUnplugged, BatteryCritical, BatteryChargeComplete, StrapFastened, StrapRemoved
  
  def before_save(alert)
    #if(alert.device_id == nil) #temporary until GW starts sending device_id with falls and panics
    if(alert.class == Fall || alert.class == Panic)
      email = CriticalMailer.deliver_device_event_notification(alert)
    elsif(alert.device == nil)
      raise "#{device_alert.class.to_s}: device_id = #{device_alert.device_id} does not exist"
    else
      email = CriticalMailer.deliver_device_event_notification(alert)
    end
  end
	
  def after_save(alert)
    Event.create(:user_id => alert.user_id, 
      :event_type => alert.class.to_s, 
      :event_id => alert.id, 
      :timestamp => alert.timestamp,
      :timestamp_server => Time.now
    )
  end
end
