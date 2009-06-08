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
		@device = DeviceBatteryReminder.find(self.device_id)
		if @device
			DeviceBatteryReminder.update_attributes(:reminder_num => self.reminder_num,:stopped_at => self.stopped_at)
		else
			DeviceBatteryReminder.create(:id => self.device_id,:reminder_num => self.reminder_num,:stopped_at => self.stopped_at)
		end
	end
	
	def self.most_recent_reminder(device_id)
		BatteryReminder.find_by_device_id(device_id,:order => 'created_at DESC')
	end
	
	def self.send_reminders
		RAILS_DEFAULT_LOGGER.warn("BatteryReminder.send_reminders running at #{Time.now}")
		@devices = DeviceBatteryReminder.find(:all)		
		@devices.each do |device|
			#@most_recent = BatteryReminder.most_recent_reminder(device.id)
			if (device.stopped_at == nil) 
				if device.reminder_num == 1 and (device.updated_at > (device.created_at + 7200) or device.updated_at < (device.created_at + 10200))
					BatteryReminder.create(:device_id => device.id, :reminder_num => 2)
				elsif device.reminder_num == 2 and device.updated_at < (device.created_at + 10200)
					BatteryReminder.create(:device_id => device.id, :reminder_num => 3)
				end
			end
		end
	end
end
