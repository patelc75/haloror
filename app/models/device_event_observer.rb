class DeviceEventObserver < ActiveRecord::Observer
  include ServerInstance
  observe BatteryPlugged, BatteryUnplugged, BatteryCritical, BatteryChargeComplete, StrapFastened, StrapRemoved
  
  def before_save(event)
    if event.user_id < 1 or event.user == nil
      raise "#{event.class.to_s}: user_id = #{event.user_id} is invalid"
    elsif event.device_id < 1 or event.device == nil
      raise "#{event.class.to_s}: device_id = #{event.device_id} does not exist"
    else
      CriticalMailer.deliver_device_event_caregiver(event)
    end
  end
  
  def after_save(alert)
    Event.create_event(alert.user_id, alert.class.to_s, alert.id, alert.timestamp)
  end
end
