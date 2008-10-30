# This alert indicates that a device that went offline via an
# GatewayOfflineAlert has come back online.

class GatewayOnlineAlert < ActiveRecord::Base
  belongs_to :device
  include Priority
  def after_save
    device.users.each do |user|
      Event.create_event(user.id, GatewayOnlineAlert.class_name, id, created_at)
      CriticalMailer.deliver_background_task_notification(self, user)
    end
  end
  
  def to_s
    "Gateway back online"
  end
end 
