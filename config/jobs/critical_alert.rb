include UtilityHelper

ActiveRecord::Base.allow_concurrency = true

SCHEDULER.schedule_every('10s') { RAILS_DEFAULT_LOGGER.debug("Job scheduler from #{__FILE__} is running at #{Time.now}") }

SCHEDULER.schedule_every(CRITICAL_ALERT_JOB_TIME, :blocking => true) { 
  begin
    DeviceAlert.job_process_crtical_alerts() 
    ActiveRecord::Base.verify_active_connections!()
  rescue Exception => e
    UtilityHelper.log_message("DeviceAlert.job_process_crtical_alerts::Exception:: #{e}", e)
  rescue Timeout::Error => e
    UtilityHelper.log_message("DeviceAlert.job_process_crtical_alerts::Timeout::Error:: #{e}", e)
  rescue
    UtilityHelper.log_message("DeviceAlert.job_process_crtical_alerts::UNKNOWN::Error")         
  end
}
