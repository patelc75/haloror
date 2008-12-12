require 'simplehttp'
class EventActionObserver < ActiveRecord::Observer
  def before_save(event_action)
    if event_action[:send_email] != false
      email = CriticalMailer.deliver_call_center_operator(event_action)
      if event_action.description == "accepted"
        send_to_backup(event_action)
      end
      if event_action.description == "resolved"
        email = CriticalMailer.deliver_call_center_caregiver(event_action)   
      end
    end
  end
  
  def after_save(event_action)
    Event.create_event(event_action.event.user_id, EventAction.class_name, event_action.id,event_action.created_at)
  end
  
  def send_to_backup(event_action)
    host = ServerInstance.current_host_short_string()
    if host == 'HALO'
      send_it('crit2.myhalomonitor.com', event_action)
    elsif host == 'sdev'
      send_it('sdev-crit2.myhalomonitor.com', event_action)
    end
  end
  
  def send_it(host, event_action)
    event = event_action.event
    http = SimpleHttp.new "https://#{host}/call_center_accept/accept"
    http.basic_authentication SYSTEM_USERNAME, SYSTEM_PASSWORD
    http.post "timestamp=#{event.timestamp.to_s}&user_id=#{event.user_id}&operator_id=#{event_action.user_id}"
  end
end
