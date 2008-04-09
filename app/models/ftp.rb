class Ftp < ActiveRecord::Base
  has_many :firmware_upgrades
end
