require 'simplehttp'
class EventActionObserver < ActiveRecord::Observer
  def before_save(event_action)
    if event_action[:send_email] != false
      email = CriticalMailer.deliver_call_center_operator(event_action)
      if event_action.description == "accepted"
        send_to_backup('accepted', event_action)
      end
      if event_action.description == "resolved"
        email = CriticalMailer.deliver_call_center_caregiver(event_action)  
        send_to_backup('resolved', event_action) 
      end
    end
  end
  
  def after_save(event_action)
    Event.create_event(event_action.event.user_id, EventAction.class_name, event_action.id,event_action.created_at)
  end
  
  def send_to_backup(description, event_action)
    host_short = ServerInstance.current_host_short_string()
    host = ServerInstance.current_host
    if host_short == 'HALO' && !ServerInstance.in_hostname?('crit2')
      send_it(description, 'crit2.data.halomonitor.com', event_action)
    elsif host_short == 'SDEV' && !ServerInstance.in_hostname?('crit2')
      send_it(description, 'sdev.crit2.data.halomonitor.com', event_action)
    end
  end
  
  def send_it(description, host, event_action)
    event = event_action.event
    http = SimpleHttp.new "URI.parse(https://#{host}/call_center_accept/accept)"
    http.basic_authentication SYSTEM_USERNAME, SYSTEM_PASSWORD
    http.post "description=#{description}&timestamp=#{event.timestamp.to_s}&user_id=#{event.user_id}&operator_id=#{event_action.user_id}"
  end
end
