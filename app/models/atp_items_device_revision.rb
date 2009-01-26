class AtpItemsDeviceRevision < ActiveRecord::Base
  belongs_to :atp_item
  belongs_to :device_revision
end