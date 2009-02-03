class DeviceType < ActiveRecord::Base
  has_many :device_models
  has_many :serial_number_prefixes
end