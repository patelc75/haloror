class BatteryReminder < ActiveRecord::Base
	def before_save(event)
		if self.reminder_num == 3
			CriticalDeviceEventObserver.before_save(event)
		else
			DeviceEventObserver.before_save(event)
		end
	end
	
	def after_save(event)
		if self.reminder_num == 3
			CriticalDeviceEventObserver.after_save(event)
		else
			DeviceEventObserver.after_save(event)
		end
	end
	
	def self.most_recent_reminder(device_id,user_id)
		self.find_by_device_id_and_user_id(device_id,user_id,:order => 'created_at')
	end
	
	def self.send_reminders
		@devices = BatteryReminder.find(:all,:group => :device_id)
		@devices.each do |reminder|
			@most_recent = BatteryReminder.most_recent_reminder(reminder.device_id,reminder.user_id)
			if @most_recent.stopped_at == nil and self.updated_at > 7200 or self.updated_at < 10200
				if @most_recent.reminder_num == 1
					
				elsif @most_recent.reminder_num == 2 and self.updated_at < 10200
				
				end
			end
		end
	end
end
