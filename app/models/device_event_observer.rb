class DeviceEventObserver < ActiveRecord::Observer
  include ServerInstance
  observe Fall, Panic, BatteryPlugged, BatteryUnplugged, BatteryCritical, BatteryChargeComplete, StrapFastened, StrapRemoved
  
  def before_save(event)
    if event.user_id < 1 or event.user == nil
      raise "#{event.class.to_s}: user_id = #{event.user_id} is invalid"
    elsif event.class == Fall or event.class == Panic #temporary until GW starts sending device_id with falls and panics
      CriticalMailer.deliver_device_event_operator(event)
      if(ServerInstance.current_host_short_string() != "ATL-WEB1")
        CriticalMailer.deliver_device_event_caregiver(event)
      end
    elsif event.device_id < 1 or event.device == nil
      raise "#{event.class.to_s}: device_id = #{event.device_id} does not exist"
    else
      CriticalMailer.deliver_device_event_caregiver(event)
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
