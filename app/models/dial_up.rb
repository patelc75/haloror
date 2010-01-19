class DialUp < ActiveRecord::Base
  acts_as_audited
  belongs_to :user,:foreign_key => 'created_by'
  has_and_belongs_to_many :gateways
  validates_uniqueness_of :phone_number
end

class DialUpNum < DialUp
	
end
