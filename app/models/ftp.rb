class Ftp < ActiveRecord::Base
  has_one :firmware_upgrade
end
