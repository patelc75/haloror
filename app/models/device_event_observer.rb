class DeviceEventObserver < ActiveRecord::Observer
  include ServerInstance
  observe BatteryPlugged, BatteryUnplugged, BatteryChargeComplete, StrapFastened, StrapRemoved
  
  def before_save(event)
 	DeviceAlert.notify_caregivers(event)
  end
  
  def after_save(alert)
    Event.create_event(alert.user_id, alert.class.to_s, alert.id, alert.timestamp)
  end

end
