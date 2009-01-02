require 'net/http'
require 'net/https'
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
    unless host == 'localhost'
      if ServerInstance.in_hostname?('crit1')
        host.gsub!('crit1', 'crit2')
      else
        host.gsub!('crit2', 'crit1')
      end
      send_it(description, host, event_action)
    end
  end
  
  def send_it(description, host, event_action)
    event = event_action.event
    url = URI.parse("https://#{host}:443/call_center_accept/accept")
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth SYSTEM_USERNAME, SYSTEM_PASSWORD
    req.set_form_data({"description" => description, 'timestamp' => event.timestamp.to_s, "user_id" => event.user_id, "operator_id" => event_action.user_id}, ';')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    resp = http.start {|h| h.request(req) }
    RAILS_DEFAULT_LOGGER.warn resp.to_s
  end
end
