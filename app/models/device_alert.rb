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
    "We have detected a #{alert_name} event for #{user.name} (#{user_id}) at #{UtilityHelper.format_datetime_readable(timestamp,user)} "
  end
  
  def event_type_numeric
    # FIXME: TODO: fill out these event types properly
    case event_type
      when "Fall" then "001"
      when "Panic" then "002"
      when "GwAlarmButton" then "003"
      when "CallCenterFollowUp" then "004"
      else "000"
  	end
  end
end
