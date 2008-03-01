SCHEDULER.schedule_every('10s') { ActiveRecord::Base.logger.debug("Job scheduler is running at #{Time.now}") }
SCHEDULER.schedule_every('10m') { MgmtQuery.job_detect_disconnected_users }


