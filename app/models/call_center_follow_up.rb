class CallCenterFollowUp < ActiveRecord::Base
  belongs_to :device
  belongs_to :user
  belongs_to :event
  belongs_to :call_center_session
  
  
  def to_s
    "Follow Up for #{event.event_type}"
  end
end