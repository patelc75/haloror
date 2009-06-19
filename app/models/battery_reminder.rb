class BatteryReminder < DeviceAlert
	set_table_name "battery_reminders"
	belongs_to :user
	belongs_to :device
	include Priority
	def priority
      return IMMEDIATE
    end
	
    def to_s
   	  "Battery has approx. #{time_remaining} minutes left for #{user.name} at #{UtilityHelper.format_datetime_readable(created_at, user)}"   	  
    end
  
  
    def before_save
    	if self.reminder_num == 3
			DeviceAlert.notify_operators_and_caregivers(self)
		else
			DeviceAlert.notify_carigivers(self)
		end
    end
    
    def after_save
    	Event.create_event(self.user_id, self.class.to_s, self.id, self.created_at)
    	@device = DeviceBatteryReminder.find_by_device_id(self.device_id)
		if @device
			@device.update_attributes(:reminder_num => self.reminder_num,:stopped_at => self.stopped_at,:time_remaining => self.time_remaining)
		else
			DeviceBatteryReminder.create(:device_id => self.device_id,:user_id => self.user_id,:reminder_num => self.reminder_num,:stopped_at => self.stopped_at,:time_remaining => self.time_remaining)
		end
    end
    
    def email_body
   	  "#{user.name}'s battery has approximately #{time_remaining} minutes left for as of #{UtilityHelper.format_datetime_readable(created_at, user)}. Please charge the battery immediately"
    end
    
	def self.most_recent_reminder(device_id)
		BatteryReminder.find_by_device_id(device_id,:order => 'created_at DESC')
	end
	
	def self.send_reminders
		 
		include UtilityHelper
    
		RAILS_DEFAULT_LOGGER.warn("BatteryReminder.send_reminders running at #{Time.now}")
		@devices = DeviceBatteryReminder.find(:all)		
		@devices.each do |device|
			#@most_recent = BatteryReminder.most_recent_reminder(device.id)
			user = User.find(device.user_id)
			if (device.stopped_at == nil and Time.now.utc.hour + get_timezone_offset(user).to_i < 21 and Time.now.utc.hour + get_timezone_offset(user).to_i > 8) 
				if ((Time.now.utc.hour + get_timezone_offset(user).to_i) == 20 and (Time.now.utc.strftime("%M").to_i + get_timezone_offset(user).to_i) > 15 and (Time.now.strftime("%M").to_i + get_timezone_offset(user).to_i) < 31 and device.reminder_num < 3)
					time_remaining = device.time_remaining - (BATTERY_REMINDER_TWO / 60) 
					BatteryReminder.create(:device_id => device.device_id, :reminder_num => 3,:user_id => device.user_id,:time_remaining => time_remaining)
				elsif ((Time.now.utc.hour + get_timezone_offset(user).to_i) == 20 and (Time.now.utc.strftime("%M").to_i + get_timezone_offset(user).to_i) > 30)
				else
					if device.reminder_num == 1 and ((Time.now.utc + get_timezone_offset(user).to_i) > (device.created_at + BATTERY_REMINDER_TWO) and device.updated_at < (device.created_at + BATTERY_REMINDER_THREE))
						time_remaining = device.time_remaining - (BATTERY_REMINDER_TWO / 60) 
						BatteryReminder.create(:device_id => device.device_id, :reminder_num => 2,:user_id => device.user_id,:time_remaining => time_remaining)
					elsif device.reminder_num == 2 and (Time.now.utc + get_timezone_offset(user).to_i) < (device.created_at + BATTERY_REMINDER_THREE)
						time_remaining = device.time_remaining - (BATTERY_REMINDER_THREE / 60) + (BATTERY_REMINDER_TWO / 60)
						BatteryReminder.create(:device_id => device.device_id, :reminder_num => 3,:user_id => device.user_id,:time_remaining => time_remaining)
					end
				end
				#if condition for BATTERY_REMINDER_CALL_CENTER_CUT_OFF - BATTERY_REMINDER_POLL_RATE  (call center(operator) mail condition between 8:15 and 8:30) and reminder_num < 3
			end
		end
	end
end
