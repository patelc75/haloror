class EventActionObserver < ActiveRecord::Observer
  def before_save(event_action)
    email = CriticalMailer.deliver_call_center_operator(event_action)
    if event_action.description == "resolved"
      email = CriticalMailer.deliver_call_center_caregiver(event_action)   
    end
  end
  
  def after_save(event_action)
    Event.create_event(event_action.event.user_id, EventAction.class_name, event_action.id,event_action.created_at)
  end
end
