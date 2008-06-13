class MgmtResponse < ActiveRecord::Base
  has_many :mgmt_cmds
  has_one :device_info
end
