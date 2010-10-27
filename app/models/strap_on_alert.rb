class StrapOnAlert < ActiveRecord::Base
  belongs_to :device 
  belongs_to :user
  
  include Priority
  def before_save
    self.user_id = device.users.first.id                  
  end  
  def after_save
    Event.create_event(user_id, StrapOnAlert.class_name, id, created_at)
    CriticalMailer.deliver_non_critical_caregiver_email(self)  
    CriticalMailer.deliver_non_critical_caregiver_text(self)    
  end
  
  def to_s
    "Strap back on for #{user.name} (#{user.id})"
  end
           
  def email_body    
    "Hello,\n\nOn #{UtilityHelper.format_datetime(created_at,user)}, we have detected that #{user.name} (#{user.id}) put their chest strap back \n\n" +
    "- Halo Staff"  
  end  
end