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
    "We have detected a #{alert_name} event for #{user.name} (#{user_id}) at #{UtilityHelper.format_datetime(timestamp,user)} "
  end
  
  def event_type_numeric
    # FIXME: TODO: fill out these event types properly
    case self.class.name
      when "Fall" then "001"
      when "Panic" then "002"
      when "GwAlarmButton" then "003"
      #when "CallCenterFollowUp" then "004"
      when "BatteryReminder" then "100"
  	  when "StrapOff" then "101"
  	  when "GatewayOfflineAlert" then "102"
  	  when "DeviceUnavailableAlert" then "103"	
      else "000"
  	end
  end
  
  
  def self.notify_caregivers(event)
    CriticalMailer.deliver_device_event_caregiver(event)
  end
    
  def self.notify_operators_and_caregivers(event)
    if event.class == CallCenterFollowUp
      CriticalMailer.deliver_device_event_admin(event)
    else
        begin
          if event.user.is_halouser_of? Group.find_by_name('criticalhealth')
            CriticalHealthClient.alert(event.user.id, CriticalHealthClient.event_type_string(event.event.class.name),event.timestamp)
          end
          if event.user.is_halouser_of? Group.find_by_name('SafetyCare')
            if event.user.profile
              if !event.user.profile.account_number.blank?
              	#don't need to filter because safetycare filters by IP
                #if ServerInstance.in_hostname?('dfw-web1') or ServerInstance.in_hostname?('dfw-web2') or ServerInstance.in_hostname?('atl-web1')
                  SafetyCareClient.alert(event.user.profile.account_number, SafetyCareClient.event_type_numeric(event.event.class.name))
                #end
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
    end
  end
  
  def self.job_process_crtical_alerts
    ethernet_system_timeout = SystemTimeout.find_by_mode('ethernet')
    dialup_system_timeout   = SystemTimeout.find_by_mode('dialup')
    
    critical_alerts = []
    
    critical_alerts += Panic.find(:all, :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{dialup_system_timeout.critical_event_delay_sec/60} minutes'", :order => "timestamp asc")
    critical_alerts += Fall.find(:all, :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{dialup_system_timeout.critical_event_delay_sec/60} minutes'", :order => "timestamp asc")
    critical_alerts += GwAlarmButton.find(:all, :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{dialup_system_timeout.critical_event_delay_sec/60} minutes'", :order => "timestamp asc")
    
    #not going to filter access_mode == 'dialup' because access_mode is not yet reliable according to corey
    #{}"id in (select device_id from access_mode_statuses where mode = 'dialup') " <<    
    
    #sort by timestamp, instead of timestamp_server in case GW sends them out of order in the alert_bundle
    critical_alerts.sort_by { |event| event[:timestamp] }.each do |crit|
      #RAILS_DEFAULT_LOGGER.info("crit.class = #{crit.class}, crit.timestamp_server = #{crit.class}\n")
      crit.call_center_pending = false
      crit.timestamp_call_center = Time.now
      crit.save
    end
  end
end
