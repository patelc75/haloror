class DevicesKit < ActiveRecord::Base
  belongs_to :device
  belongs_to :kit
end