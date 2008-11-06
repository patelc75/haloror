class DeviceType < ActiveRecord::Base
  has_many :work_orders
  has_many :device_type_work_orders
  has_many :atp_items_device_types
  has_many :atp_items, :through => :atp_items_device_types
  has_many :devices
end