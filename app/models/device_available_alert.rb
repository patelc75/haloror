# "Device Available" means the chest strap is back in range following
# a DeviceUnavailableAlert

class DeviceAvailableAlert < ActiveRecord::Base

  belongs_to :device
  belongs_to :user

  def before_save
    self.user_id = device.users.first.id unless device.blank? || device.users.blank?
  end

  def after_save
    if user.blank?
      # Tue Oct 26 22:39:37 IST 2010
      # QUESTION: This is a critical event. What action should be taken here?
      #   * send email to safety_care?
    else
      transaction do
        Event.create_event(user.id, DeviceAvailableAlert.class_name, id, created_at)
        CriticalMailer.deliver_non_critical_caregiver_email(self, user)
        CriticalMailer.deliver_non_critical_caregiver_text(self, user)
      end
    end
  end

  def to_s 
    user.nil? ? user_info = "" : user_info = " for #{user.name} (#{user.id})"        
    "Device Available (back in range or battery alive again) " + user_info
  end

  def email_body
    user.nil? ? user_info = "the myHalo" : user_info = "(#{user.id}) #{user.name}'s"            
    "Hello,\n\nOn #{UtilityHelper.format_datetime(created_at,user)}, we detected that " + user_info + " device is available again. The device is either back in range or the battery is alive again.\n\n" +
    "- Halo Staff"  
  end  
end 
