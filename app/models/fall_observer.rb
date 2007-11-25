class FallObserver < ActiveRecord::Observer
	def before_save(fall)
		email = CriticalMailer.deliver_fall_notification(fall.user)
	end
end
