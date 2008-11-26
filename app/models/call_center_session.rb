class CallCenterSession < ActiveRecord::Base
  has_many :call_center_steps
  belongs_to :event
  has_one :call_center_wizard
end