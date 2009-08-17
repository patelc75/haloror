class BatteryReminder < DeviceAlert
	set_table_name "battery_reminders"
	belongs_to :user
	belongs_to :device
	belongs_to :battery_critical
	include Priority
	def priority
      return IMMEDIATE
    end
	
    def to_s
   	  "Battery has approx. #{time_remaining < 0 ? 0:time_remaining} minutes left for #{user.name} at #{UtilityHelper.format_datetime_readable(created_at, user)}"   	  
    end

    def email_body
   	  "#{user.name}'s battery has approximately #{time_remaining < 0 ? 0:time_remaining} minutes left for as of #{UtilityHelper.format_datetime_readable(created_at, user)}. Please charge the battery immediately"
    end
  
    def after_save
    	if self.reminder_num == 3
			DeviceAlert.notify_operators_and_caregivers(self)
		else
			DeviceAlert.notify_carigivers(self)
		end
		
    	Event.create_event(self.user_id, self.class.to_s, self.id, self.created_at)
    	
    	@device = DeviceBatteryReminder.find_by_device_id(self.device_id)
		
    	if @device
			@device.update_attributes(:reminder_num => self.reminder_num,
									  :stopped_at => self.stopped_at,
									  :time_remaining => self.time_remaining,
									  :battery_critical_id => self.battery_critical_id)
		else
			DeviceBatteryReminder.create(:device_id => self.device_id,
										 :user_id => self.user_id,
										 :reminder_num => self.reminder_num,
										 :stopped_at => self.stopped_at,
										 :time_remaining => self.time_remaining,
										 :battery_critical_id => self.battery_critical_id)
		end
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
			local_time = user.profile.tz.utc_to_local(Time.now)
			morning = Time.local(Time.now.year,Time.now.month,Time.now.day,8,0,0)
			night = Time.local(Time.now.year,Time.now.month,Time.now.day,20,30,0)
			
			#make sure it's between 8AM and 9PM
			if (device.stopped_at == nil and local_time < night and local_time > morning) 
				
				#RAILS_DEFAULT_LOGGER.warn("device.stopped_at= #{device.stopped_at} 
				#Time.now.utc.hour=#{Time.now.utc.hour} get_timezone_offset(user)=#{get_timezone_offset(user)}")

				Time.now.utc.hour=#{Time.now.utc.hour} get_timezone_offset(user)=#{get_timezone_offset(user)}")
				
				#if between 8:15PM and 8:30PM, send a reminder
				eight_fifteen = Time.local(Time.now.year,Time.now.month,Time.now.day,20,15,0)
				eight_thirty = Time.local(Time.now.year,Time.now.month,Time.now.day,20,30,0)
				if (local_time >= eight_fifteen and local_time <= eight_thirty and device.reminder_num < 3)
					
					#RAILS_DEFAULT_LOGGER.warn('Time.now.utc.strftime("%M").to_i= #{Time.now.utc.strftime("%M").to_i} device.reminder_num=#{device.reminder_num}')

					time_remaining = device.time_remaining - (BATTERY_REMINDER_TWO / 60) 
				
					BatteryReminder.create(:device_id => device.device_id, :reminder_num => 3,:user_id => device.user_id,
										   :time_remaining => time_remaining,:battery_critical_id => device.battery_critical_id)
				
				else
					if  device.reminder_num == 1 and 
						( local_time > (device.created_at + BATTERY_REMINDER_TWO) and 
						device.updated_at < (device.created_at + BATTERY_REMINDER_THREE))
						
						time_remaining = device.time_remaining - (BATTERY_REMINDER_TWO / 60) 
						BatteryReminder.create(:device_id => device.device_id, 
												:reminder_num => 2,
												:user_id => device.user_id,
												:time_remaining => time_remaining,
												:battery_critical_id => device.battery_critical_id)
					
												
					elsif device.reminder_num == 2 and local_time < (device.created_at + BATTERY_REMINDER_THREE)
						
						time_remaining = device.time_remaining - (BATTERY_REMINDER_THREE / 60) + (BATTERY_REMINDER_TWO / 60)
						BatteryReminder.create(:device_id => device.device_id, 
											   :reminder_num => 3,
											   :user_id => device.user_id,
											   :time_remaining => time_remaining,
											   :battery_critical_id => device.battery_critical_id)
					end
				end
			end
		end
	end
end
