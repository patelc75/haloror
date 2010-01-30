class DialUpAlert < ActiveRecord::Base
	
  def number=(number)
  	self.phone_number = number
  end
end
