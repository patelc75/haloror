class Gateway < ActiveRecord::Base
  has_and_belongs_to_many :dial_ups
end
