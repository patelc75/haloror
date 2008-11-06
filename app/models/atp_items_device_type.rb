class AtpItemsDeviceType < ActiveRecord::Base
  belongs_to :atp_item
  belongs_to :device_type
end