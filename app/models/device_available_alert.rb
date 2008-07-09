# "Device Available" means the chest strap is back in range following
# a DeviceUnavailableAlert

class DeviceAvailableAlert < ActiveRecord::Base
  
  belongs_to :device

  def after_save
    transaction do 
      device.users.each do |user|
        Event.create(:user_id => user.id, 
                     :event_type => DeviceAvailableAlert.class_name, 
                     :event_id => id, 
                     :timestamp => created_at || Time.now)
        
        CriticalMailer.deliver_background_task_notification(self, user)
      end
    end
  end
  
  def to_s
    "Device Available (back in range or battery alive again) on #{created_at}"
  end
end 
