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
  
  def self.notify_caregivers(event)
    CriticalMailer.deliver_device_event_caregiver(event)
  end

  def self.notify_call_center_and_partners(event)
    groups = event.user.is_halouser_for_what
    #all_call_centers_successful = false
    groups.each do |group|
      if !group.nil? and group.sales_type == "call_center"
        model_string = (group.name.camelcase + "Client")
        begin
          if model_string.constantize.alert(event.class.name, event.user.id, event.user.profile.account_number, event.timestamp) == false
            event.timestamp_call_center = nil
          end
        rescue Exception => e
          CriticalMailer.deliver_monitoring_failure("Exception: #{e}", event)
          UtilityHelper.log_message_critical("DeviceAlert.notify_call_center_and_partners::Exception:: #{e} : #{event.to_s}", e)
          event.timestamp_call_center = nil
        rescue Timeout::Error => e
          CriticalMailer.deliver_monitoring_failure("Timeout: #{e}", event)
          UtilityHelper.log_message_critical("DeviceAlert.notify_call_center_and_partners::Timeout::Error:: #{e} : #{event.to_s}", e)
          event.timestamp_call_center = nil
        rescue
          CriticalMailer.deliver_monitoring_failure("UNKNOWN error", event)
          UtilityHelper.log_message_critical("DeviceAlert.notify_call_center_and_partners::UNKNOWN::Error: #{event.to_s}")
          event.timestamp_call_center = nil
        end
      end          
    end
  end  
  
  def self.notify_operators(event)
    if event.class == CallCenterFollowUp
      CriticalMailer.deliver_device_event_admin(event)
    else
      CriticalMailer.deliver_device_event_operator_text(event)
      CriticalMailer.deliver_device_event_operator(event)
    end
  end
  
  def self.job_process_crtical_alerts
    RAILS_DEFAULT_LOGGER.warn("DeviceAlert.job_process_crtical_alerts running at #{Time.now}")
    ethernet_system_timeout = SystemTimeout.find_by_mode('ethernet')
    dialup_system_timeout   = SystemTimeout.find_by_mode('dialup')
    
    critical_alerts = []
    
    critical_alerts += Panic.find(:all, :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{dialup_system_timeout.critical_event_delay_sec} seconds'", :order => "timestamp asc")
    critical_alerts += Fall.find(:all, :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{dialup_system_timeout.critical_event_delay_sec} seconds'", :order => "timestamp asc")
    critical_alerts += GwAlarmButton.find(:all, :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{dialup_system_timeout.critical_event_delay_sec} seconds'", :order => "timestamp asc")
    
    #not going to filter access_mode == 'dialup' because access_mode is not yet reliable according to corey
    #{}"id in (select device_id from access_mode_statuses where mode = 'dialup') " <<    

    #sort by timestamp, instead of timestamp_server in case GW sends them out of order in the alert_bundle
    critical_alerts.sort_by { |event| event[:timestamp] }.each do |crit|
      crit.call_center_pending = false
      crit.timestamp_call_center = Time.now
      crit.save
      RAILS_DEFAULT_LOGGER.warn("DeviceAlert.job_process_crtical_alerts: Critical alert sent to call center: #{crit.class}(#{crit.id}), #{Time.now}\n")  
    end
  end
end
