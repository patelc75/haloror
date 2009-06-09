class BatteryReminderObserver < ActiveRecord::Observer
  include ServerInstance
  observe BatteryReminder
  
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
end
