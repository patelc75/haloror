class StrapOnAlert < DeviceAlert
  set_table_name "strap_on_alerts"
  belongs_to :device
  include Priority
  def after_save
    device.users.each do |user|
      Event.create(:user_id => user.id, 
        :event_type => StrapOnAlert.class_name, 
        :event_id => id, 
        :timestamp => created_at || Time.now)
      CriticalMailer.deliver_strap_on_notification(self, user)
    end
  end
  
  def to_s
    "Strap back on on #{created_at}"
  end
end