class CriticalDeviceEventObserver 
    include ServerInstance
    observe Fall, Panic, GwAlarmButton

    def before_save(event)
      if event.user_id < 1 or event.user == nil
        raise "#{event.class.to_s}: user_id = #{event.user_id} is invalid"
      else 
        CriticalMailer.deliver_device_event_operator_text(event)
        CriticalMailer.deliver_device_event_operator(event)
        if(ServerInstance.current_host_short_string() != "ATL-WEB1")
          CriticalMailer.deliver_device_event_caregiver(event)
        end
      end
    end

    def after_save(alert)
      Event.create_event(alert.user_id, alert.class.to_s, alert.id, alert.timestamp)
    end
end