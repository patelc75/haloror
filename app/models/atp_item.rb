class AtpItem < ActiveRecord::Base
  has_many :atp_item_results
  has_many :device_revisions, :through => :atp_items_device_revisions
  has_many :atp_items_device_revisions
end