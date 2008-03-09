class MgmtCmd < ActiveRecord::Base
  has_one :mgmt_response
  has_one :mgmt_ack
  has_one :mgmt_query
  
  belongs_to :device
  
  belongs_to :cmd, :polymorphic => true
end
