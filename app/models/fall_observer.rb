class FallObserver < ActiveRecord::Observer
  def before_save(fall)
    email = CriticalMailer.deliver_device_event_notification(fall)
  end
	
  def after_save(fall)
    Event.create(:user_id => fall.user_id, 
      :event_type => Fall.class_name, 
      :event_id => fall.id, 
      :timestamp => fall.timestamp)
  end
end
