class MgmtCmd < ActiveRecord::Base
  has_one :mgmt_response
  has_one :mgmt_ack
  belongs_to :device
end
