class UserIntake < ActiveRecord::Base
	has_and_belongs_to_many :users
	validates_numericality_of :order_id
	
  def created_by_user_name
  	User.find(self.created_by).name
  end

end
