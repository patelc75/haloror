class DeviceInfo < ActiveRecord::Base
  belongs_to :device
  belongs_to :mgmt_response
  belongs_to :device_info, :polymorphic => true
end
