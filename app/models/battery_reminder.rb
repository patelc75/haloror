class BatteryReminder < ActiveRecord::Base
    def to_s
   	  "Battery has approx. #{get_hours_remaining} hours left for #{{user.name}} at #{UtilityHelper.format_datetime_readable(timestamp, user)}"
    end
   
    def email_body
   	  "#{{user.name}}'s battery has approximately #{get_hours_remaining} hours left for as of #{UtilityHelper.format_datetime_readable(timestamp, user)}. Please charge the battery immediately"
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
				if device.reminder_num == 1 and (device.updated_at > (device.created_at + BATTERY_REMINDER_TWO) or device.updated_at < (device.created_at + BATTERY_REMINDER_THREE))
					BatteryReminder.create(:device_id => device.id, :reminder_num => 2)
				elsif device.reminder_num == 2 and device.updated_at < (device.created_at + BATTERY_REMINDER_THREE)
					BatteryReminder.create(:device_id => device.id, :reminder_num => 3)
				end
			end
		end
	end
end
