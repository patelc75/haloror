class FirmwareUpgrade < ActiveRecord::Base
  belongs_to :ftp
  has_many :mgmt_cmds, :as => :cmd
end
