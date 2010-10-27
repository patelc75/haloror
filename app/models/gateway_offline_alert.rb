# Indicates an outage has occurred between this user's device and our
# servers. The primary use of this class is to separate out detection
# of an outage from the actual processing of it to ensure we can
# quickly detect and then process in parallel.

class GatewayOfflineAlert < ActiveRecord::Base 
  include Priority
  belongs_to :device
  belongs_to :user  
                          
  # If we have detected an outage after our retry period, notify the
  # user immediately
  def after_save
    if number_attempts == MAX_ATTEMPTS_BEFORE_NOTIFICATION
      logger.debug("[GatewayOfflineAlert] Detected an outage for device #{device_id}. Alert ID #{id}. Number attempts: #{number_attempts}")
      
      device.users.each do |user|    
        self.user_id = user.id         
        Event.create_event(user.id, GatewayOfflineAlert.class_name, id, created_at)        
        CriticalMailer.deliver_non_critical_caregiver_email(self, user)
        CriticalMailer.deliver_non_critical_caregiver_text(self, user)        
      end
    end
  end
  
  def to_s
    user.nil? ? user_info = "" : user_info = " for #{user.name} (#{user.id})"    
    "Gateway back online" + user_info
  end
  
  def email_body
    user.nil? ? user_info = "" : user_info = " for #{user.name} (#{user.id})"
    "Hello,\n\nWe have detected that the gateway went offline" + user_info +
      "\n\n- Halo Staff"
  end
end 
