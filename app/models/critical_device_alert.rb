class CriticalDeviceAlert < DeviceAlert
  def priority
    return IMMEDIATE
  end
  
  def before_create 
    self.timestamp_server = Time.now.utc
    self.call_center_timed_out = false
    self.call_center_pending = user.is_halouser_of_what.any?(&:is_call_center?)
    true  #   return TRUE to continue executing further callbacks
  end

  def after_create 
    Event.create_event( self.user_id, self.class.to_s, self.id, self.timestamp)
    unless (ServerInstance.host?( "ATL-WEB1", "CRIT2"))
      DeviceAlert.notify_caregivers( self)
    end
    true #   return TRUE to continue executing further callbacks
  end
  
  def self.job_process_crtical_alerts
    RAILS_DEFAULT_LOGGER.warn("CriticalDeviceAlert.job_process_crtical_alerts running at #{Time.now}")
    
    critical_alerts = []
    critical_alerts += Panic.find(:all, :include => [:user => :profile], :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{SystemTimeout.dialup.critical_event_delay_sec} seconds'", :order => "timestamp asc")
    critical_alerts += Fall.find(:all, :include => [:user => :profile], :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{SystemTimeout.dialup.critical_event_delay_sec} seconds'", :order => "timestamp asc")
    critical_alerts += GwAlarmButton.find(:all, :include => [:user => :profile], :conditions => "call_center_pending is true and now() > timestamp_server + interval '#{SystemTimeout.dialup.critical_event_delay_sec} seconds'", :order => "timestamp asc")
    #not going to filter access_mode == 'dialup' because access_mode is not yet reliable according to corey
    #{}"id in (select device_id from access_mode_statuses where mode = 'dialup') " <<    

    #sort by timestamp, instead of timestamp_server in case GW sends them out of order in the alert_bundle
    unless critical_alerts.blank?
      # WARNING: The current implementation of sort_by generates an array of tuples containing the original collection element and the mapped value
      # critical_alerts.sort_by { |event| event[:timestamp] }.each do |crit|
      #   * QUESTION: why do we sort this? we are looping through the array anyways
      critical_alerts.sort! {|a,b| a.timestamp <=> b.timestamp } if critical_alerts.length > 1
      critical_alerts.each do |crit|
        crit.call_center_timed_out = true
        crit.timestamp_call_center = Time.now #if (crit.respond_to?(:call_center_number_valid?) ? crit.call_center_number_valid? : true)
        # https://redmine.corp.halomonitor.com/issues/3076
        # crit.send(:update_without_callbacks) # save
        crit.save
        RAILS_DEFAULT_LOGGER.warn("CriticalDeviceAlert.job_process_crtical_alerts: Critical alert sent to call center: #{crit.class}(#{crit.id}), #{Time.now}\n")  
      end
    end
  end
end
