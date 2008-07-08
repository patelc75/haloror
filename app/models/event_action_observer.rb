class EventActionObserver < ActiveRecord::Observer
  def before_save(event_action)
    email = CriticalMailer.deliver_call_center_notification(event_action)
  end
  
  def after_save(event_action)
    Event.create(:user_id => event_action.event.user_id, 
      :event_type => EventAction.class_name, 
      :event_id => event_action.id, 
      :timestamp => event_action.created_at)
  end
end
