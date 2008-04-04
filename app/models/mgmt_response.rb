class MgmtResponse < ActiveRecord::Base
  belongs_to :mgmt_cmd
  has_one :device_info
end
