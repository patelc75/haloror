class PanicObserver < ActiveRecord::Observer
	def before_save(panic)
		email = CriticalMailer.deliver_panic_notification(panic.user)
	end
end
