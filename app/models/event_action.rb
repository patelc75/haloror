class EventAction < ActiveRecord::Base
  include UtilityHelper
  belongs_to :user
  belongs_to :event
  
  def to_s
    "#{event.user.name if event}'s <a href='/call_center/event_details/#{event.id}/'>#{event.event_type if event}</a> marked #{description} by Operator #{user.name if user}"
  end
  
  include Priority
  def priority
    return IMMEDIATE
  end
  
  def email_body
    "#{event.event_type} #{description} on #{UtilityHelper.format_datetime(Time.now, event.user)}\n\n" +
      "Event ID:#{event.id} User:#{event.user.name} (#{event.user_id})\n\n" +
      "Sincerely, Halo Staff"
  end
end
