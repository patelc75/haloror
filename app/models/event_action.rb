class EventAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  
  def to_s
    "#{event.user.name}'s #{event.event_type} #{description} by Operator #{user.name}"
  end
  
  include Priority
  def priority
    return IMMEDIATE
  end
end
