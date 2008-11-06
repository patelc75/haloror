class AtpItem < ActiveRecord::Base
  has_one :atp_item_result
  has_many :device_types, :through => :atp_items_device_types
end