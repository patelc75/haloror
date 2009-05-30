include UtilityHelper

## This echoes a line to the log file every 10 seconds just to make
## sure things are running - eventually, we should remove it.
ActiveRecord::Base.allow_concurrency = true

SCHEDULER.schedule_every('10s') { RAILS_DEFAULT_LOGGER.debug("Safetycare Test scheduler is running at #{Time.now}") }

SCHEDULER.schedule_every(SAFETYCARE_HEARTBEAT_TIME) {
  begin
    RAILS_DEFAULT_LOGGER.debug("Heartbeat at #{Time.now}")
    
    SafetyCareClient.heartbeat()
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.debug("Exception: #{e} at #{Time.now}")
  rescue Timeout::Error => e
RAILS_DEFAULT_LOGGER.debug("Timeout: #{e} at #{Time.now}")
  rescue
    RAILS_DEFAULT_LOGGER.debug("Unknown failure at #{Time.now}")
  end
}