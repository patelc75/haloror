## This echoes a line to the log file every 10 seconds just to make
## sure things are running - eventually, we should remove it.
ActiveRecord::Base.allow_concurrency = true

SCHEDULER.schedule_every('10s') { ActiveRecord::Base.logger.debug("Job scheduler is running at #{Time.now}") }

SCHEDULER.schedule_every(GATEWAY_OFFLINE_POLL_RATE) { 
    MgmtQuery.job_detect_disconnected_users 
    ActiveRecord::Base.verify_active_connections!()
     rescue Exception => e
       RAILS_DEFAULT_LOGGER.warn("MgmtQuery.job_detect_disconnected_users::Exception:: #{e}")
     rescue Timeout::Error => e
       RAILS_DEFAULT_LOGGER.warn("MgmtQuery.job_detect_disconnected_users::Timeout::Error:: #{e}")
     rescue
       RAILS_DEFAULT_LOGGER.warn("MgmtQuery.job_detect_disconnected_users::UNKNOWN::Error")         
     end
    }

SCHEDULER.schedule_every(DEVICE_UNAVAILABLE_POLL_RATE) { 
    Vital.job_detect_unavailable_devices 
    ActiveRecord::Base.verify_active_connections!()
     rescue Exception => e
       RAILS_DEFAULT_LOGGER.warn("Vital.job_detect_unavailable_devices::Exception:: #{e}")
     rescue Timeout::Error => e
       RAILS_DEFAULT_LOGGER.warn("Vital.job_detect_unavailable_devices::Timeout::Error:: #{e}")
     rescue
       RAILS_DEFAULT_LOGGER.warn("MgmtQuery.job_detect_disconnected_users::UNKNOWN::Error")         
     end
     }

SCHEDULER.schedule_every(STRAP_OFF_POLL_RATE) { 
    StrapOffAlert.job_detect_straps_off
    ActiveRecord::Base.verify_active_connections!()
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("StrapOffAlert.job_detect_straps_off::Exception:: #{e}")
    rescue Timeout::Error => e
      RAILS_DEFAULT_LOGGER.warn("StrapOffAlert.job_detect_straps_off::Timeout::Error:: #{e}")
    rescue
      RAILS_DEFAULT_LOGGER.warn("MgmtQuery.job_detect_disconnected_users::UNKNOWN::Error")         
    end
     }

SCHEDULER.schedule_every(EMAIL_NOTIFICATION_RATE) { 
    Email.notify_by_priority 
    ActiveRecord::Base.verify_active_connections!()
    rescue Exception => e
       RAILS_DEFAULT_LOGGER.warn("Email.notify_by_priority::Exception:: #{e}")
    rescue Timeout::Error => e
       RAILS_DEFAULT_LOGGER.warn("Email.notify_by_priority::Timeout::Error:: #{e}")
    rescue
       RAILS_DEFAULT_LOGGER.warn("MgmtQuery.job_detect_disconnected_users::UNKNOWN::Error")         
    end
   }
