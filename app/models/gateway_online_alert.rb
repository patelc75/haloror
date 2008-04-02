# This alert indicates that a device that went offline via an
# GatewayOfflineAlert has come back online.

class GatewayOnlineAlert < ActiveRecord::Base
  belongs_to :device

  def after_save
    device.users.each do |user|
      Event.create(:user_id => user.id, 
                   :event_type => GatewayOnlineAlert.class_name, 
                   :event_id => id, 
                   :timestamp => created_at || Time.now)
      CriticalMailer.deliver_gateway_online_notification(self)
    end
  end
end 
