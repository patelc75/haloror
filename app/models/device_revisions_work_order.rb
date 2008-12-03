class DeviceRevisionsWorkOrder < ActiveRecord::Base
  belongs_to :device_revision
  belongs_to :work_order
end