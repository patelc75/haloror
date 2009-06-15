class BatteryCritical < ActiveRecord::Base
  set_table_name "battery_criticals"
  belongs_to :user
  def after_save
  	if self.mode == 'stop'
  		@most_recent = BatteryReminder.most_recent_reminder(self.device_id)
		@most_recent.update_attributes(:stopped_at => Time.now)	if @most_recent
		DeviceAlert.notify_carigivers(self)
	elsif self.mode == 'start'
		BatteryReminder.create(:reminder_num => 1,:user_id =>self.user_id ,:device_id => self.device_id)
	elsif self.mode == nil
		DeviceAlert.notify_carigivers(self)
  	end
  end
  
  def to_s
    "Battery critically low on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def email_body
  	if mode == 'stop'
  		"Battery critical state resolved on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  	else
   	   "Battery critically low on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
    end
  end
  
  def self.new_initialize(random=false)
    model = self.new
    if random
      model.percentage = rand(10)
      model.time_remaining = rand(100)
    else
      model.percentage = 10
      model.time_remaining = 100
    end
    return model    
  end
  
 
  
end
