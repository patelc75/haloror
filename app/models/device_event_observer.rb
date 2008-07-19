class DeviceEventObserver < ActiveRecord::Observer
  observe Fall, Panic, BatteryPlugged, BatteryUnplugged, BatteryCritical, BatteryChargeComplete, StrapFastened, StrapRemoved
  
  def before_save(event)
    if(event.device_id == nil) #temporary until GW starts sending device_id with falls and panics
      email = CriticalMailer.deliver_device_event_operator(event) if event.class == Fall or event.class == Panic
      email = CriticalMailer.deliver_device_event_caregiver(event)
    elsif(event.device == nil)
      raise "#{device_alert.class.to_s}: device_id = #{device_alert.device_id} does not exist"
    else
      email = CriticalMailer.deliver_device_event_operator(event) if event.class == Fall or event.class == Panic
      email = CriticalMailer.deliver_device_event_caregiver(event) 
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
