# This alert indicates that a device that went offline via an
# GatewayOfflineAlert has come back online.

class GatewayOnlineAlert < ActiveRecord::Base
  belongs_to :device
  include Priority
  def after_save
    device.users.each do |user|
      Event.create(:user_id => user.id, 
        :event_type => GatewayOnlineAlert.class_name, 
        :event_id => id, 
        :timestamp => created_at || Time.now)
      CriticalMailer.deliver_background_task_notification(self, user)
    end
  end
  
  def to_s
    "Gateway back online on #{created_at}"
  end
end 
