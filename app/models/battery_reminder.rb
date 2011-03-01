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
   	if reminder_num == 4
   	  "Battery no longer critical for #{user.name} (#{user.id})"
 	  else
 	    "Battery Low reminder ##{reminder_num} for #{user.name} (#{user.id})"
 	    #"Battery Reminder ##{reminder_num}: Approx. #{time_remaining < 0 ? 0:time_remaining} minutes left for #{user.name} as of #{UtilityHelper.format_datetime(updated_at, user)}" 
    end
  end

  def email_body
    if reminder_num == 4
      to_s
 	  else
   	  "Battery low reminder ##{reminder_num}: (#{user.id}) #{user.name}'s battery has approximately #{time_remaining < 0 ? 0:time_remaining} minutes left for as of #{UtilityHelper.format_datetime(updated_at, user)}. Please charge the battery immediately"
 	  end
  end
  
  def after_create
  	if self.reminder_num == 3
  	  #DeviceAlert.notify_call_center_and_partners(self)      #do not send TCP alerts to call center until they are ready

		  # FIXME: if battery reminder ever goes to operators we need rename created_at to timestamp to match falls, panic since it's considered a critical alert
		  #DeviceAlert.notify_operators(self)     #we do NOT send battery reminders email, text to SafetyCare
		  
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
    @st = SystemTimeout.find_by_mode('ethernet')
    conds << "now() < updated_at + interval '#{(@st.battery_reminder_two_sec + @st.battery_reminder_three_sec)*2} seconds'"
    conds << "reminder_num < 3"
		@devices = DeviceBatteryReminder.find(:all, :conditions => conds.join(' and '), :order => "updated_at asc")	
		@devices.each do |device|
			user = User.find(device.user_id) if device.user_id
    
      if user and user.profile and user.profile.time_zone
        Time.zone = user.profile.time_zone
        now = Time.now.in_time_zone
        
  			eight_am = Time.zone.local(now.year,now.month,now.day,8,0,0) #8:00AM
  			eight_thirty_pm = Time.zone.local(now.year,now.month,now.day,20,30,0) #8:30PM

  			if (now > eight_am and now < eight_thirty_pm) #make sure it's not during the middle of the night
  				eight_fifteen_pm = Time.zone.local(now.year,now.month,now.day,20,15,0)
  				if (now >= eight_fifteen_pm) #if between 8:15PM and 8:30PM, skip to the third battery reminder	
  					time_remaining = device.time_remaining - (@st.battery_reminder_two_sec / 60) 
  					BatteryReminder.create(:device_id => device.device_id, :reminder_num => 3,:user_id => device.user_id,
  										   :time_remaining => time_remaining,:battery_critical_id => device.battery_critical_id)
  				else
  					if device.reminder_num == 1 and Time.now > (device.updated_at + @st.battery_reminder_two_sec)
  						time_remaining = device.time_remaining - (@st.battery_reminder_two_sec / 60) 
  						BatteryReminder.create(:device_id => device.device_id, 
  												:reminder_num => 2,
  												:user_id => device.user_id,
  												:time_remaining => time_remaining,
  												:battery_critical_id => device.battery_critical_id)
												
  					elsif device.reminder_num == 2 and Time.now > (device.updated_at + @st.battery_reminder_three_sec)						
  						time_remaining = device.time_remaining - (@st.battery_reminder_three_sec / 60)
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