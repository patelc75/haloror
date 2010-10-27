# "Device Unavailable" means the chest strap is out of the wireless
# range (or the strap’s battery died). By contrast, the Gateway
# Offline event (aka GatewayOfflineAlert) means that the WAN or LAN is down at
# the user’s home. The difference is that:
# 
# 1) The Vitals table is polled instead of the MgmtQueries table
# 2) The alert is triggered if the Vitals has not been posted to for a
#    specific interval AND the chest strap is "fastened". 
#
# The status of the chest strap is denormalized into the table named
# device_strap_status which records the latest event for a given device
# (i.e. is the strap fastened or removed)
#

class DeviceUnavailableAlert < ActiveRecord::Base
  
  belongs_to :device
  belongs_to :user
  
  def before_save
    self.user_id = device.users.first.id                  
  end
  
  def after_save
    if reconnected_at.nil? && number_attempts == MAX_ATTEMPTS_BEFORE_NOTIFICATION 
      logger.debug("[DeviceUnavailableAlert] Detected an outage for device #{device_id}. Alert ID #{id}. Number attempts: #{number_attempts}")

      Event.create_event(user.id, DeviceUnavailableAlert.class_name, id, created_at)        
      CriticalMailer.deliver_non_critical_caregiver_email(self, user)  
      CriticalMailer.deliver_non_critical_caregiver_text(self, user)        
    end
  end
  
  def to_s
    "Device Unavailable (out of range or battery dead) for #{user.name} (#{user.id})"
  end
  
  def email_body    
    "Hello,\n\nOn #{UtilityHelper.format_datetime(created_at,user)}, we have detected that (#{user.id}) #{user.name}'s device is unvailable becuase of either out of range or dead battery.\n\n" +
    "- Halo Staff"  
  end
end 
