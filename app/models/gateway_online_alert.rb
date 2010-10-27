# This alert indicates that a device that went offline via an
# GatewayOfflineAlert has come back online.

class GatewayOnlineAlert < ActiveRecord::Base
  belongs_to :device
  belongs_to :user  
  include Priority
  def after_save
    device.users.each do |user|
      self.user_id = user.id
      Event.create_event(user.id, GatewayOnlineAlert.class_name, id, created_at)
      CriticalMailer.deliver_non_critical_caregiver_email(self, user)  
      CriticalMailer.deliver_non_critical_caregiver_text(self, user)      
    end
  end
  
  def to_s
    user.nil? ? user_info = "" : user_info = " for #{user.name} (#{user.id})"
    "Gateway back online" + user_info
  end 
  
  def email_body
    user.nil? ? user_info = "" : user_info = " for #{user.name} (#{user.id})"
    "Hello,\n\nWe have detected that the gateway is back online" + user_info +
      "\n\n- Halo Staff"
  end
end 
