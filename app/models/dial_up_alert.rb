class DialUpAlert < ActiveRecord::Base
  belongs_to :device
  def after_create
    CriticalMailer.deliver_dialup_800_abuse(self)
  end
  
  def number=(number)
  	self.phone_number = number
  end
  
  def to_s
    "Dial Up Alert for #{phone_number} at #{UtilityHelper.format_datetime(created_at,device.users[0])}" 
  end

  def email_body
   	"Dial Up Alert for #{phone_number} at #{UtilityHelper.format_datetime(created_at,device.users[0])}"
  end
  
end
