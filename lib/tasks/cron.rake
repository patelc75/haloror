require 'time'
require "digest/sha2"
namespace :cron do  
  desc "background job to process critical_alert"
  task :critical_alert => :environment  do
    ActiveRecord::Base.allow_concurrency = true
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
  end
end