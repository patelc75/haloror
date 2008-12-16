class Group < ActiveRecord::Base
  acts_as_authorizable
  has_many :emergency_numbers
end