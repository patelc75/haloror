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
    CriticalMailer.deliver_non_critical_caregiver_email(event)
    CriticalMailer.deliver_non_critical_caregiver_text(event)
  end

  # Wed Oct 27 01:14:31 IST 2010
  #   * Exception found in mail.halomonitoring.com
  #     dfw-web1.halomonitor.com.Message = [HALO]BatteryReminder.send_reminders::Exception:: undefined method `timestamp_call_center=' for #<BatteryReminder:0x2aaaafc299d8>
  #   * Added condition to the assignment expression
  def self.notify_call_center_and_partners(event)
    groups = event.user.is_halouser_for_what
    #all_call_centers_successful = false
    groups.each do |group|
      if !group.nil? and group.sales_type == "call_center"
        model_string = (group.name.camelcase + "Client")
        begin
          if model_string.constantize.alert(event.class.name, event.user.id, event.user.profile.account_number, event.timestamp) == false
            event.timestamp_call_center = nil if event.respond_to?( :timestamp_call_center)
          end
        rescue Exception => e
          CriticalMailer.deliver_monitoring_failure("Exception: #{e}", event)
          UtilityHelper.log_message_critical("DeviceAlert.notify_call_center_and_partners::Exception:: #{e} : #{event.to_s}", e)
          event.timestamp_call_center = nil if event.respond_to?( :timestamp_call_center)
        rescue Timeout::Error => e
          CriticalMailer.deliver_monitoring_failure("Timeout: #{e}", event)
          UtilityHelper.log_message_critical("DeviceAlert.notify_call_center_and_partners::Timeout::Error:: #{e} : #{event.to_s}", e)
          event.timestamp_call_center = nil if event.respond_to?( :timestamp_call_center)
        rescue
          CriticalMailer.deliver_monitoring_failure("UNKNOWN error", event)
          UtilityHelper.log_message_critical("DeviceAlert.notify_call_center_and_partners::UNKNOWN::Error: #{event.to_s}")
          event.timestamp_call_center = nil if event.respond_to?( :timestamp_call_center)
        end
      end          
    end
  end  
  
  def self.notify_operators(event)
    CriticalMailer.deliver_device_event_operator_text(event)
    CriticalMailer.deliver_device_event_operator(event)
  end
  
  # 
  #  Tue Mar  1 03:18:16 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4223
  #   * shifted to critical device alert rb
  # def self.job_process_crtical_alerts
  #   RAILS_DEFAULT_LOGGER.warn("DeviceAlert.job_process_crtical_alerts running at #{Time.now}")
  #   ethernet_system_timeout = SystemTimeout.find_by_mode('ethernet')
  #   dialup_system_timeout   = SystemTimeout.find_by_mode('dialup')
  #   
  #   critical_alerts = []
  #   critical_alerts += Panic.find(:all, :include => [:user => :profile], :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{dialup_system_timeout.critical_event_delay_sec} seconds'", :order => "timestamp asc")
  #   critical_alerts += Fall.find(:all, :include => [:user => :profile], :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{dialup_system_timeout.critical_event_delay_sec} seconds'", :order => "timestamp asc")
  #   critical_alerts += GwAlarmButton.find(:all, :include => [:user => :profile], :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{dialup_system_timeout.critical_event_delay_sec} seconds'", :order => "timestamp asc")
  #   #not going to filter access_mode == 'dialup' because access_mode is not yet reliable according to corey
  #   #{}"id in (select device_id from access_mode_statuses where mode = 'dialup') " <<    
  # 
  #   #sort by timestamp, instead of timestamp_server in case GW sends them out of order in the alert_bundle
  #   unless critical_alerts.blank?
  #     # WARNING: The current implementation of sort_by generates an array of tuples containing the original collection element and the mapped value
  #     # critical_alerts.sort_by { |event| event[:timestamp] }.each do |crit|
  #     critical_alerts.sort! {|a,b| a.timestamp <=> b.timestamp } if critical_alerts.length > 1
  #     critical_alerts.each do |crit|
  #       # 
  #       #  Mon Feb 28 23:08:41 IST 2011, ramonrails
  #       #   * changed during the voice call on skype
  #       # crit.call_center_pending = false
  #       crit.call_center_timed_out = true
  #       #
  #       # if the model respond_to? call_center_number_valid? method, then check it before timestamo
  #       # otherwise just time stamp it
  #       crit.timestamp_call_center = Time.now #if (crit.respond_to?(:call_center_number_valid?) ? crit.call_center_number_valid? : true)
  #       # https://redmine.corp.halomonitor.com/issues/3076
  #       # crit.send(:update_without_callbacks) # save
  #       crit.save
  #       RAILS_DEFAULT_LOGGER.warn("DeviceAlert.job_process_crtical_alerts: Critical alert sent to call center: #{crit.class}(#{crit.id}), #{Time.now}\n")  
  #     end
  #   end
  # end
end
