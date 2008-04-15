# Indicates an outage has occurred between this user's device and our
# servers. The primary use of this class is to separate out detection
# of an outage from the actual processing of it to ensure we can
# quickly detect and then process in parallel.

class GatewayOfflineAlert < ActiveRecord::Base
  MAX_ATTEMPTS_BEFORE_NOTIFICATION = 5
  include Priority
  belongs_to :device

  # If we have detected an outage after our retry period, notify the
  # user immediately
  def after_save
    if number_attempts >= MAX_ATTEMPTS_BEFORE_NOTIFICATION
      logger.debug("[GatewayOfflineAlert] Detected an outage for device #{device_id}. Alert ID #{id}. Number attempts: #{number_attempts}")
      
      device.users.each do |user|
        Event.create(:user_id => user.id, 
                     :event_type => GatewayOfflineAlert.class_name, 
                     :event_id => id, 
                     :timestamp => created_at || Time.now)
        
        CriticalMailer.deliver_gateway_offline_notification(self, user)
      end
    end
  end
end 
