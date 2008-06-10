## This echoes a line to the log file every 10 seconds just to make
## sure things are running - eventually, we should remove it.
ActiveRecord::Base.allow_concurrency = true

SCHEDULER.schedule_every('10s') { ActiveRecord::Base.logger.debug("Job scheduler is running at #{Time.now}") }

SCHEDULER.schedule_every(GATEWAY_OFFLINE_POLL_RATE) { MgmtQuery.job_detect_disconnected_users }

SCHEDULER.schedule_every(DEVICE_UNAVAILABLE_POLL_RATE) { Vital.job_detect_unavailable_devices }

SCHEDULER.schedule_every(EMAIL_NOTIFICATION_RATE) { Email.notify_by_priority }
