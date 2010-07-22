class DialUpAlert < ActiveRecord::Base
  # associations -------------
  
  belongs_to :device
  
  # triggers ------------
  
  def after_create
    CriticalMailer.deliver_dialup_800_abuse(self)
  end
  
  # instance methods ---------------
  
  # https://redmine.corp.halomonitor.com/issues/3159
  #   Resolve this triage alert by checking the Dial up Status table. If latest entry does not start with 18 as first two digits
  # WARNING: needs test coverage
  def resolved?
    # * device exists
    # * last dial up status for the device exists
    # * last dial up status for the device is after this alter
    # * and the last dial up status number begins with "18"
    # * any exception/error causes this to fail. same as not resolved
    device && device.last_dial_up_status && (device.last_dial_up_status.created_at > created_at) && (device.last_dial_up_status.phone_number[0..1] == "18") rescue false
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
