include UtilityHelper

## This echoes a line to the log file every 10 seconds just to make
## sure things are running - eventually, we should remove it.
ActiveRecord::Base.allow_concurrency = true

SCHEDULER.schedule_every('10s') { RAILS_DEFAULT_LOGGER.debug("Job scheduler from #{__FILE__} is running at #{Time.now}") }
SCHEDULER.schedule(DAILY_REPORT_TIME) { 
  begin
    CriticalMailer.deliver_lost_data_daily()
    ActiveRecord::Base.verify_active_connections!()
  rescue Exception => e
    UtilityHelper.log_message("CriticalMailer.deliver_lost_data_daily()::Exception:: #{e}", e)
  rescue Timeout::Error => e
    UtilityHelper.log_message("CriticalMailer.deliver_lost_data_daily()::Timeout::Error:: #{e}", e)
  rescue
    UtilityHelper.log_message("CriticalMailer.deliver_lost_data_daily()::UNKNOWN::Error")         
  end
}

SCHEDULER.schedule(DAILY_REPORT_TIME) { 
  begin
    CriticalMailer.deliver_device_not_worn_daily()
    ActiveRecord::Base.verify_active_connections!()
  rescue Exception => e
    UtilityHelper.log_message("CriticalMailer.deliver_device_not_worn_daily()::Exception:: #{e}", e)
  rescue Timeout::Error => e
    UtilityHelper.log_message("CriticalMailer.deliver_device_not_worn_daily()::Timeout::Error:: #{e}", e)
  rescue
    UtilityHelper.log_message("CriticalMailer.deliver_device_not_worn_daily()::UNKNOWN::Error")         
  end
}

SCHEDULER.schedule(DAILY_REPORT_TIME) { 
  begin
    CriticalMailer.deliver_successful_user_logins_daily()
    ActiveRecord::Base.verify_active_connections!()
  rescue Exception => e
    UtilityHelper.log_message("CriticalMailer.deliver_successful_user_logins_daily()::Exception:: #{e}", e)
  rescue Timeout::Error => e
    UtilityHelper.log_message("CriticalMailer.deliver_successful_user_logins_daily()::Timeout::Error:: #{e}", e)
  rescue
    UtilityHelper.log_message("CriticalMailer.deliver_successful_user_logins_daily()::UNKNOWN::Error")         
  end
}
