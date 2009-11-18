class DeviceEventObserver < ActiveRecord::Observer
  include ServerInstance
  observe BatteryPlugged, BatteryUnplugged, BatteryChargeComplete, StrapFastened, StrapRemoved
  
  def before_save(event)
    if UtilityHelper.validate_event(event) == true
 	    DeviceAlert.notify_caregivers(event)
 	  end
  end
  
  def after_save(alert)
    Event.create_event(alert.user_id, alert.class.to_s, alert.id, alert.timestamp)
  end
end