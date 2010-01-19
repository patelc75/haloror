class DialUpStatus < ActiveRecord::Base
  belongs_to :device
  def after_create
    if (status == "fail" && consecutive_fails > 3 && configured == "old") or (status == "fail" && configured == "new") 
      device.users.each do |user|
        Event.create_event(user.id, self.class.name, id, created_at)
      end
    end
  end
  def to_s
    "Dial Up failure for #{phone_number} at #{UtilityHelper.format_datetime(updated_at, device.users[0])}" 
  end

  def email_body
   	"Dial Up failure for #{phone_number} at #{UtilityHelper.format_datetime(updated_at, device.users[0])}"
  end
end
