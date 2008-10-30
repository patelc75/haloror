# "Device Available" means the chest strap is back in range following
# a DeviceUnavailableAlert

class DeviceAvailableAlert < ActiveRecord::Base
  
  belongs_to :device

  def after_save
    transaction do 
      device.users.each do |user|
        Event.create_event(user.id, DeviceAvailableAlert.class_name, id, created_at)        
        CriticalMailer.deliver_background_task_notification(self, user)
      end
    end
  end
  
  def to_s
    "Device Available (back in range or battery alive again)"
  end
end 
