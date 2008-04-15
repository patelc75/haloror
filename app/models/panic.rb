class Panic < ActiveRecord::Base
	belongs_to :user
	include Priority
	def priority
	  return IMMEDIATE
	end
end
