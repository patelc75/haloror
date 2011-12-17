class CriticalDeviceAlert < DeviceAlert
  def priority
    return IMMEDIATE
  end
  
  def before_create 
    self.timestamp_server = Time.now.utc
    self.call_center_timed_out = false
    pend = false

    # call_center_pending flags ON when any halouser-group is call_center
    # WARNING: nil returned in group array will cause save! to fail   
    self.call_center_pending = 
      if (!self.resolved.blank?)  #if resolved = 'manual' or 'auto'
        false
      else
        if self.class.name == "GwAlarmButton"
          matching_fall  = Fall.find (:first,:conditions => { :resolved_timestamp => self.timestamp, :user_id => user.id })
          matching_panic = Panic.find(:first,:conditions => { :resolved_timestamp => self.timestamp, :user_id => user.id })           
          pend = (matching_fall.nil? and matching_panic.nil?)
          self.resolved = "manual" if pend == false  #so no caregiver emails are sent in the after_create()
        end            

        pend = user.is_halouser_of_what.compact.any?(&:is_call_center?) if pend == true # unless user.blank?
        pend                                                                    
      end 
    true
  # rescue Exception => e
  #   CriticalMailer.deliver_monitoring_failure("Exception: #{e}", event)
  #   UtilityHelper.log_message_critical("CriticalDeviceAlert.before_create::Exception:: #{e} : #{event.to_s}", e)
  end

  def after_create 
    Event.create_event( self.user_id, self.class.to_s, self.id, self.timestamp)
    if (!ServerInstance.host?( "ATL-WEB1", "CRIT2") and self.resolved.blank?)
      DeviceAlert.notify_caregivers( self)
    end
    true #   return TRUE to continue executing further callbacks
  end
  
  def self.job_process_crtical_alerts
    RAILS_DEFAULT_LOGGER.warn("CriticalDeviceAlert.job_process_crtical_alerts running at #{Time.now}")
    
    critical_alerts = []

    [Panic, Fall, GwAlarmButton].each do |_klass|
      critical_alerts += _klass.all({
        :include    => [ :user => :profile ],
        :conditions => [ "call_center_pending = ? AND ( ? > (timestamp_server + interval '? seconds'))", true, Time.now, SystemTimeout.dialup.critical_event_delay_sec ]
      })
    end
    #not going to filter access_mode == 'dialup' because access_mode is not yet reliable according to corey
    #{}"id in (select device_id from access_mode_statuses where mode = 'dialup') " <<    

    #sort by timestamp, instead of timestamp_server in case GW sends them out of order in the alert_bundle
    unless critical_alerts.blank?
      critical_alerts.sort! {|a,b| a.timestamp <=> b.timestamp } if critical_alerts.length > 1
      critical_alerts.each do |crit| 
        crit.call_center_timed_out = true
        crit.timestamp_call_center = Time.now #if (crit.respond_to?(:call_center_number_valid?) ? crit.call_center_number_valid? : true)        
        crit.save # crit.send(:update_without_callbacks) # save         
        RAILS_DEFAULT_LOGGER.warn("CriticalDeviceAlert.job_process_crtical_alerts: Critical alert sent to call center: #{crit.class}(#{crit.id}), #{Time.now}\n")  
      end
    end
  end
end
