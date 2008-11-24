class CallCenterStepsGroup < ActiveRecord::Base
  has_many :call_center_steps
  belongs_to :event
end
