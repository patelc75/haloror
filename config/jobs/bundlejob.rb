include UtilityHelper

## This echoes a line to the log file every 10 seconds just to make
## sure things are running - eventually, we should remove it.
ActiveRecord::Base.allow_concurrency = true

#SCHEDULER.schedule_every('10s') { RAILS_DEFAULT_LOGGER.debug("Job scheduler from #{__FILE__} is running at #{Time.now}") }

SCHEDULER.schedule_every(BUNDLE_JOB_DIAL_UP_TIME, :blocking => true) { 
  begin
    BundleJob.job_process_bundles() 
    ActiveRecord::Base.verify_active_connections!()
  rescue Exception => e
    UtilityHelper.log_message("BundleJob.job_process_bundles::Exception:: #{e}", e)
  rescue Timeout::Error => e
    UtilityHelper.log_message("BundleJob.job_process_bundles::Timeout::Error:: #{e}", e)
  rescue
    UtilityHelper.log_message("BundleJob.job_process_bundles::UNKNOWN::Error")         
  end
}
