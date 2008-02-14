class PanicObserver < ActiveRecord::Observer
	def before_save(panic)
		email = CriticalMailer.deliver_panic_notification(panic.user)
	end
	
	def after_save(panic)
		Event.create(:user_id => panic.user_id, 
					:kind => Panic.class_name, 
					:kind_id => panic.id, 
					:timestamp => panic.timestamp)
	end
end