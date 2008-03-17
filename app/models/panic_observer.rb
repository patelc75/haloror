class PanicObserver < ActiveRecord::Observer
  def before_save(panic)
    email = CriticalMailer.deliver_panic_notification(panic)
  end
	
  def after_save(panic)
    Event.create(:user_id => panic.user_id, 
      :event_type => Panic.class_name, 
      :event_id => panic.id, 
      :timestamp => panic.timestamp)
  end
end