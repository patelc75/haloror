class BatteryReminder < ActiveRecord::Base
	set_table_name "battery_reminders"
	belongs_to :user
	belongs_to :device
	include Priority
	def priority
      return IMMEDIATE
    end
	
    def to_s
   	  "Battery has approx. #{time_remaining} hours left for #{user.name} at #{UtilityHelper.format_datetime_readable(created_at, user)}"   	  
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
    	@device = DeviceBatteryReminder.find_by_id(self.device_id)
		if @device
			@device.update_attributes(:reminder_num => self.reminder_num,:stopped_at => self.stopped_at)
		else
			DeviceBatteryReminder.create(:id => self.device_id,:reminder_num => self.reminder_num,:stopped_at => self.stopped_at)
		end
    end
    
    def email_body
   	  "#{user.name}'s battery has approximately #{time_remaining} hours left for as of #{UtilityHelper.format_datetime_readable(created_at, user)}. Please charge the battery immediately"
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
