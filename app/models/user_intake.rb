class UserIntake < ActiveRecord::Base
	has_and_belongs_to_many :users
	validates_numericality_of :order_id
end
