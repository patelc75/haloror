class Device < ActiveRecord::Base
  has_one :device_info
  has_many :mgmt_cmds
end
