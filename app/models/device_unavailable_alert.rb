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
  
  def after_save
    if reconnected_at.nil? && number_attempts >= GatewayOfflineAlert::MAX_ATTEMPTS_BEFORE_NOTIFICATION 
      logger.debug("[DeviceUnavailableAlert] Detected an outage for device #{device_id}. Alert ID #{id}. Number attempts: #{number_attempts}")

      device.users.each do |user|
        Event.create(:user_id => user.id, 
                     :event_type => DeviceUnavailableAlert.class_name, 
                     :event_id => id, 
                     :timestamp => created_at || Time.now)
        
        CriticalMailer.deliver_device_unavailable_alert_notification(self, user)
      end
    end
  end
end 
