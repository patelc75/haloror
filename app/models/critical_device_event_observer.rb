class CriticalDeviceEventObserver  < ActiveRecord::Observer
    include ServerInstance
    include UtilityHelper
    observe Fall, Panic, GwAlarmButton, CallCenterFollowUp

    def before_save(event)
      if event.user_id < 1 or event.user == nil
        raise "#{event.class.to_s}: user_id = #{event.user_id} is invalid"
      elsif event.class == CallCenterFollowUp
        CriticalMailer.deliver_device_event_admin(event)
      elsif event.class == GwAlarmButton
        CriticalMailer.deliver_gw_alarm(event)
      else 
        # refs 1523:
        begin
          if event.user.profile && !event.user.profile.account_number.blank?
            SafetyCareClient.alert(event.user.profile.account_number, event.event_type_numeric)
          else
            CriticalMailer.deliver_monitoring_failure("No profile or missing account number!", event)
          end
        rescue Exception => e
          CriticalMailer.deliver_monitoring_failure("Exception: #{e}", event)
          UtilityHelper.log_message("SafetyCareClient.alert::Exception:: #{e} : #{event.to_s}", e)
        rescue Timeout::Error => e
          CriticalMailer.deliver_monitoring_failure("Timeout: #{e}", event)
          UtilityHelper.log_message("SafetyCareClient.alert::Timeout::Error:: #{e} : #{event.to_s}", e)
        rescue
          CriticalMailer.deliver_monitoring_failure("UNKNOWN error", event)
          UtilityHelper.log_message("SafetyCareClient.alert::UNKNOWN::Error: #{event.to_s}")         
        end

        CriticalMailer.deliver_device_event_operator_text(event)
        CriticalMailer.deliver_device_event_operator(event)
        if(ServerInstance.current_host_short_string() != "ATL-WEB1")
          CriticalMailer.deliver_device_event_caregiver(event)
        end
      end
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