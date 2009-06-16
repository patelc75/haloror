class CriticalDeviceEventObserver  < ActiveRecord::Observer
    include ServerInstance
    include UtilityHelper
    observe Fall, Panic, GwAlarmButton, CallCenterFollowUp

    def before_save(event)
      DeviceAlert.notify_operators_and_caregivers(event)
    end

    def after_save(alert)
      Event.create_event(alert.user_id, alert.class.to_s, alert.id, alert.timestamp)
      if alert.class == Fall or alert.class == Panic
    	gw_timeout = GwAlarmButtonTimeout.create(:pending => true, 
                                              :device_id => alert.device_id, 
                                              :user_id => alert.user_id,
                                              :event_id => alert.id,
                                              :event_type => alert.class.class_name,
                                              :timestamp => Time.now)
        spawn do
          sleep(GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT) 
          #RAILS_DEFAULT_LOGGER.warn("spawn Checking CallCenterDeferred: #{deferred.id}")
          gw_timeout = GwAlarmButtonTimeout.find(gw_timeout.id)
          if gw_timeout && gw_timeout.pending
          	CriticalMailer.deliver_gw_alarm(gw_timeout)
    		Event.create_event(gw_timeout.user_id, GwAlarmButtonTimeout.class_name, gw_timeout.id, gw_timeout.timestamp)
          end
        end
      end
    end
end