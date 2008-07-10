class DeviceAlert < ActiveRecord::Base
  belongs_to :device
  belongs_to :user
  include Priority
  include UtilityHelper
  
  def self.get_latest_event_by_user(type, user_id)
    event = StrapRemoved.find(:first, :order => "timestamp DESC", :conditions => "user_id='#{user_id}'")
    if(event == nil)
      event = Event.new
      event.timestamp = "Jan 1 1970 00:00:00 -0000"
      event.event_type = "Not found"
    end
    
    event
  end
  
  def email_body
    alert_name = UtilityHelper.camelcase_to_spaced(self.class.to_s)
    #datetime = format_datetime(timestamp,user).to_time.strftime("%I:%M%p on %a %m/%d/%Y")
    "We have detected a #{alert_name} event for #{user.name} (#{user_id}) at #{UtilityHelper.format_datetime_readable(timestamp,user)} "
  end
end
