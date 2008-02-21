class DialUp < ActiveRecord::Base
  has_and_belongs_to_many :gateways
end
