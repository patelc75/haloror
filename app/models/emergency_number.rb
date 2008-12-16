class EmergencyNumber < ActiveRecord::Base
  belongs_to :group
  has_many :profiles
end