class CriticalDeviceEventObserver  < ActiveRecord::Observer
    include ServerInstance
    include UtilityHelper
    observe Fall, Panic, GwAlarmButton, CallCenterFollowUp

    def before_save(event)
      if UtilityHelper.validate_event_user(event) == true #only validating user because GW does not use the device_id
        if event.call_center_pending == false
          DeviceAlert.notify_call_center_and_partners(event)
          DeviceAlert.notify_operators(event)
        else
          if(ServerInstance.current_host_short_string() != "ATL-WEB1")
            DeviceAlert.notify_caregivers(event)
          end
        end
      end
    end

    def after_save(event)
      if event.call_center_pending == true
        Event.create_event(event.user_id, event.class.to_s, event.id, event.timestamp)
      end
=begin      
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
            gw_timeout.update_attributes(:timestamp => Time.now)
          	CriticalMailer.deliver_gw_alarm(gw_timeout)
    		    Event.create_event(gw_timeout.user_id, GwAlarmButtonTimeout.class_name, gw_timeout.id, gw_timeout.timestamp)
          end
        end
      end
=end       
    end
end