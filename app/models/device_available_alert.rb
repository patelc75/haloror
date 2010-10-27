# "Device Available" means the chest strap is back in range following
# a DeviceUnavailableAlert

class DeviceAvailableAlert < ActiveRecord::Base
  
  belongs_to :device
  belongs_to :user
  
  def before_save
    self.user_id = device.users.first.id                  
  end

  def after_save
    transaction do 
      Event.create_event(user.id, DeviceAvailableAlert.class_name, id, created_at)        
      CriticalMailer.deliver_non_critical_caregiver_email(self, user)
      CriticalMailer.deliver_non_critical_caregiver_text(self, user)
    end
  end
  
  def to_s
    "Device Available (back in range or battery alive again) for #{user.name} (#{user.id})"
  end

  def email_body    
    "Hello,\n\nOn #{UtilityHelper.format_datetime(created_at,user)}, we detected that (#{user.id}) #{user.name}'s device is available again. The device is either back in range or the battery is alive again.\n\n" +
    "- Halo Staff"  
  end  
end 
