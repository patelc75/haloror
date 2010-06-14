include UtilityHelper

## This echoes a line to the log file every 10 seconds just to make
## sure things are running - eventually, we should remove it.
ActiveRecord::Base.allow_concurrency = true

#SCHEDULER.schedule_every('10s') { RAILS_DEFAULT_LOGGER.debug("Job scheduler from #{__FILE__} is running at #{Time.now}") }

#safetycare cannot distinguish between a live heartbeat and a test heartbeat so the test heartbeat is commented out
#if ServerInstance.in_hostname?('dfw-web1') or ServerInstance.in_hostname?('dfw-web2') #or ServerInstance.in_hostname?('corp')
	SCHEDULER.schedule_every(CMS_HEARTBEAT_TIME) {
	  begin
	    CmsClient.heartbeat()
	    ActiveRecord::Base.verify_active_connections!()
	  rescue Exception => e
	    #CriticalMailer.deliver_monitoring_hertbeat_failure("Exception!", e)
	    UtilityHelper.log_message_critical("CmsClient.heartbeat::Exception:: #{e}", e)
	  rescue Timeout::Error => e
	    #CriticalMailer.deliver_monitoring_hertbeat_failure("Timeout!", e)
	    UtilityHelper.log_message_critical("CmsClient.heartbeat::Timeout::Error:: #{e}", e)
	  rescue
	    #CriticalMailer.deliver_monitoring_hertbeat_failure("UNKNOWN ERROR!")
	    UtilityHelper.log_message_critical("CmsClient.heartbeat::UNKNOWN::Error")
	  ensure
	    ActiveRecord::Base.verify_active_connections!
      # https://redmine.corp.halomonitor.com/issues/2951
      @heartbeat_socket.close if @heartbeat_socket # close socket on exception. socket will open again in next call to write
	  end
	}
#end
