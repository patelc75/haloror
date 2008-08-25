include UtilityHelper

## This echoes a line to the log file every 10 seconds just to make
## sure things are running - eventually, we should remove it.
ActiveRecord::Base.allow_concurrency = true

SCHEDULER.schedule_every('10s') { RAILS_DEFAULT_LOGGER.debug("Job scheduler is running at #{Time.now}") }

SCHEDULER.schedule_every(GATEWAY_OFFLINE_POLL_RATE) { 
  begin
    MgmtQuery.job_detect_disconnected_users 
    ActiveRecord::Base.verify_active_connections!()
  rescue Exception => e
    UtilityHelper.log_message("MgmtQuery.job_detect_disconnected_users::Exception:: #{e}", e)
  rescue Timeout::Error => e
    UtilityHelper.log_message("MgmtQuery.job_detect_disconnected_users::Timeout::Error:: #{e}", e)
  rescue
    UtilityHelper.log_message("MgmtQuery.job_detect_disconnected_users::UNKNOWN::Error")
  end
}

SCHEDULER.schedule_every(DEVICE_UNAVAILABLE_POLL_RATE) { 
  begin
    Vital.job_detect_unavailable_devices 
    ActiveRecord::Base.verify_active_connections!()
  rescue Exception => e
    UtilityHelper.log_message("Vital.job_detect_unavailable_devices::Exception:: #{e}", e)
  rescue Timeout::Error => e
    UtilityHelper.log_message("Vital.job_detect_unavailable_devices::Timeout::Error:: #{e}", e)
  rescue
    UtilityHelper.log_message("Vital.job_detect_unavailable_devices::UNKNOWN::Error")         
  end
}

SCHEDULER.schedule_every(STRAP_OFF_POLL_RATE) { 
  begin
    StrapOffAlert.job_detect_straps_off
    ActiveRecord::Base.verify_active_connections!()
  rescue Exception => e
    UtilityHelper.log_message("StrapOffAlert.job_detect_straps_off::Exception:: #{e}", e)
  rescue Timeout::Error => e
    UtilityHelper.log_message("StrapOffAlert.job_detect_straps_off::Timeout::Error:: #{e}", e)
  rescue
    UtilityHelper.log_message("StrapOffAlert.job_detect_straps_off::UNKNOWN::Error")         
  end
}

SCHEDULER.schedule_every(EMAIL_NOTIFICATION_RATE) { 
  begin
    Email.notify_by_priority 
    ActiveRecord::Base.verify_active_connections!()
  rescue Exception => e
    UtilityHelper.log_message("Email.notify_by_priority::Exception:: #{e}", e)
  rescue Timeout::Error => e
    UtilityHelper.log_message("Email.notify_by_priority::Timeout::Error:: #{e}", e)
  rescue
    UtilityHelper.log_message("Email.notify_by_priority::UNKNOWN::Error")         
  end
}


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
