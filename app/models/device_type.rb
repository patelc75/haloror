class DeviceType < ActiveRecord::Base
  has_many :atp_items_device_types
  has_many :atp_items, :through => :atp_items_device_types
  has_many :device_models
end