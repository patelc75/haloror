class DeviceTypesWorkOrder < ActiveRecord::Base
  belongs_to :work_order
  belongs_to :device_type
end