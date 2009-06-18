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
    case self.class.name
      when "Fall" then "001"
      when "Panic" then "002"
      when "GwAlarmButton" then "003"
      when "CallCenterFollowUp" then "004"
      else "000"
  	end
  end
  
  def self.notify_carigivers(event)
  	if event.user_id < 1 or event.user_id == nil
      raise "#{event.class.to_s}: user_id = #{event.user_id} is invalid"
    elsif event.device_id < 1 or event.device_id == nil
      raise "#{event.class.to_s}: device_id = #{event.device_id} does not exist"
    else
      CriticalMailer.deliver_device_event_caregiver(event)
    end
  end
  
  def self.notify_operators_and_caregivers(event)
  	if event.user_id < 1 or event.user == nil
        raise "#{event.class.to_s}: user_id = #{event.user_id} is invalid"
      elsif event.class == CallCenterFollowUp
        CriticalMailer.deliver_device_event_admin(event)
      elsif event.class == GwAlarmButton
        CriticalMailer.deliver_gw_alarm(event)
      else 
        # refs 1523:
        begin
          if event.user.is_halouser_of? Group.find_by_name('SafetyCare')
            if event.user.profile
              if !event.user.profile.account_number.blank?
              	if ServerInstance.in_hostname?('dfw-web1') or ServerInstance.in_hostname?('dfw-web2') or ServerInstance.in_hostname?('atl-web1')
                  SafetyCareClient.alert(event.user.profile.account_number, event.event_type_numeric)
                end
              else
                CriticalMailer.deliver_monitoring_failure("Missing account number!", event)
              end
            else
              CriticalMailer.deliver_monitoring_failure("Missing user profile!", event)
            end
          end
        rescue Exception => e
          CriticalMailer.deliver_monitoring_failure("Exception: #{e}", event)
          UtilityHelper.log_message("SafetyCareClient.alert::Exception:: #{e} : #{event.to_s}", e)
        rescue Timeout::Error => e
          CriticalMailer.deliver_monitoring_failure("Timeout: #{e}", event)
          UtilityHelper.log_message("SafetyCareClient.alert::Timeout::Error:: #{e} : #{event.to_s}", e)
        rescue
          CriticalMailer.deliver_monitoring_failure("UNKNOWN error", event)
          UtilityHelper.log_message("SafetyCareClient.alert::UNKNOWN::Error: #{event.to_s}")         
        end

        CriticalMailer.deliver_device_event_operator_text(event)
        CriticalMailer.deliver_device_event_operator(event)
        if(ServerInstance.current_host_short_string() != "ATL-WEB1")
          CriticalMailer.deliver_device_event_caregiver(event)
        end
      end
  end
  
end
