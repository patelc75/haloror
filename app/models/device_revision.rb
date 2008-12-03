class DeviceRevision < ActiveRecord::Base
  has_many :work_orders
  belongs_to :device_model
  has_many :devices
end