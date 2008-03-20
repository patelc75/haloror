# Indicates an outage has occurred between this user's device and our
# servers. The primary use of this class is to separate out detection
# of an outage from the actual processing of it to ensure we can
# quickly detect and then process in parallel.

class OutageAlert < ActiveRecord::Base
  MAX_ATTEMPTS_BEFORE_NOTIFICATION = 5

  belongs_to :user
  belongs_to :device

  # If we have detected an outage after our retry period, notify the
  # user immediately
  def after_create
    if number_attempts >= MAX_ATTEMPTS_BEFORE_NOTIFICATION
      logger.debug("[OutageAlert] Detected an outage for user #{device.user_id}. Alert ID #{id}. Number attempts: #{number_attempts}")

      Event.create(:user_id => device.user_id, 
                   :event_type => OutageAlert.class_name, 
                   :event_id => id, 
                   :timestamp => created_at || Time.now)

      CriticalMailer.deliver_outage_alert_notification(self)
    end
  end
end