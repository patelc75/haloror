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
   	"Battery Reminder ##{reminder_num}: Approx. #{time_remaining < 0 ? 0:time_remaining} minutes left for #{user.name} as of #{UtilityHelper.format_datetime(created_at, user)}"   if time_remaining 	  
  end

  def email_body
   	"Battery Reminder ##{reminder_num}: #{user.name}'s battery has approximately #{time_remaining < 0 ? 0:time_remaining} minutes left for as of #{UtilityHelper.format_datetime(created_at, user)}. Please charge the battery immediately"
  end
  
  def after_create
  	if self.reminder_num == 3
		  DeviceAlert.notify_operators(self)
		  DeviceAlert.notify_caregivers(self)
	  else
		  DeviceAlert.notify_caregivers(self)
	  end
	
  	Event.create_event(self.user_id, self.class.to_s, self.id, self.created_at)
  	
  	@device = DeviceBatteryReminder.find_by_device_id_and_user_id(self.device_id, self.user_id)
	
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
    conds = ["stopped_at IS NULL"]
    conds << "now() < updated_at + interval '#{BATTERY_REMINDER_THREE * 1.5} seconds'"
    conds << "reminder_num < 3"
		@devices = DeviceBatteryReminder.find(:all, :conditions => conds.join(' and '), :order => "updated_at asc")	
		@devices.each do |device|
			#@most_recent = BatteryReminder.most_recent_reminder(device.id)
			user = User.find(device.user_id) if device.user_id

      if user and user.profile and user.profile.time_zone
        Time.zone = user.profile.time_zone
        local_time = Time.now.in_time_zone(user.profile.time_zone)
  			morning = Time.zone.local(Time.now.year,Time.now.month,Time.now.day,8,0,0) #8:00AM
  			night = Time.zone.local(Time.now.year,Time.now.month,Time.now.day,20,30,0) #8:30PM

  			#make sure it's not during the middle of the night
  			if (local_time < night and local_time > morning) 
								
  				#if between 8:15PM and 8:30PM, skip to the third battery reminder
  				eight_fifteen = Time.zone.local(Time.now.year,Time.now.month,Time.now.day,20,15,0)
  				eight_thirty = Time.zone.local(Time.now.year,Time.now.month,Time.now.day,20,30,0)
  				if (local_time >= eight_fifteen and local_time <= eight_thirty and device.reminder_num < 3)
  				  
  					time_remaining = device.time_remaining - (BATTERY_REMINDER_TWO / 60) 
				
  					BatteryReminder.create(:device_id => device.device_id, :reminder_num => 3,:user_id => device.user_id,
  										   :time_remaining => time_remaining,:battery_critical_id => device.battery_critical_id)
  				else
  					if device.reminder_num == 1 and Time.now > (device.updated_at + BATTERY_REMINDER_TWO) 
  						 #and Time.now < (device.updated_at + BATTERY_REMINDER_THREE) #took out in case Rufus job dies
						
  						time_remaining = device.time_remaining - (BATTERY_REMINDER_TWO / 60) 
  						BatteryReminder.create(:device_id => device.device_id, 
  												:reminder_num => 2,
  												:user_id => device.user_id,
  												:time_remaining => time_remaining,
  												:battery_critical_id => device.battery_critical_id)
					
												
  					elsif device.reminder_num == 2 and Time.now > (device.updated_at + BATTERY_REMINDER_THREE)						
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
end
