class FallObserver < ActiveRecord::Observer
	def before_save(fall)
		email = CriticalMailer.deliver_fall_notification(fall.user)
		Event.create(:user_id => fall.user_id, :kind => Fall.class_name, :kind_id => fall.id, :timestamp => fall.timestamp)
	end
end
