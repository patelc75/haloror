class StrapOnAlert < DeviceAlert
  set_table_name "strap_on_alerts"
  belongs_to :device
  include Priority
  def after_save
    device.users.each do |user|
      Event.create_event(user.id, StrapOnAlert.class_name, id, created_at)
      CriticalMailer.deliver_background_task_notification(self, user)
    end
  end
  
  def to_s
    "Strap back on"
  end
end