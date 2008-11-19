class DeviceRevision < ActiveRecord::Base
  belongs_to :device_model
  has_many :devices
end