class BatteryCritical < ActiveRecord::Base
  set_table_name "battery_criticals"
  belongs_to :user
  belongs_to :device
  has_many :battery_reminders
	include Priority
	def priority
      return IMMEDIATE
    end
    
  def before_create
  	self.timestamp_server = Time.now.utc
  end
  
  def after_save
  	if self.mode.nil?  #backward compatibility for GWs with old code
  	  DeviceAlert.notify_caregivers(self)
  	elsif
  	  if self.mode == 'stop'
  		@most_recent = BatteryReminder.most_recent_reminder(self.device_id)
		@most_recent.update_attributes(:stopped_at => Time.now)	if @most_recent
		DeviceAlert.notify_caregivers(self)
	  elsif self.mode == 'start'
		BatteryReminder.create(:reminder_num => 1,
							   :user_id =>self.user_id ,
							   :device_id => self.device_id,
							   :time_remaining => self.time_remaining,
							   :battery_critical_id => self.id)
	  end
  	end
  end
  
  def to_s
    if mode == 'stop'
      "Battery critical state resolved on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  	else  	
      "Battery critically low on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
    end
  end
  
  def email_body
    to_s
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
