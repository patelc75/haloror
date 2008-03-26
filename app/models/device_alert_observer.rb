class DeviceAlertObserver < ActiveRecord::Observer
  observe BatteryPlugged, BatteryUnplugged, BatteryCritical, BatteryChargeComplete, StrapFastened, StrapRemoved
  
  def before_save(alert)
    email = CriticalMailer.deliver_device_alert_notification(alert)
  end
	
  def after_save(alert)
    Event.create(:user_id => alert.device.user_id, 
      :event_type => alert.class.to_s, 
      :event_id => alert.id, 
      :timestamp => alert.timestamp
    )
  end
end
