## This echoes a line to the log file every 10 seconds just to make
## sure things are running - eventually, we should remove it.
SCHEDULER.schedule_every('10s') { ActiveRecord::Base.logger.debug("Job scheduler is running at #{Time.now}") }

SCHEDULER.schedule_every('1m') { MgmtQuery.job_detect_disconnected_users }

SCHEDULER.schedule_every('1m') { Vital.job_detect_unavailable_devices }
