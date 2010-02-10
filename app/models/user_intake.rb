class UserIntake < ActiveRecord::Base
	has_and_belongs_to_many :users
	validates_numericality_of :order_id,:if => :order_present?
	
  def created_by_user_name
  	User.find(self.created_by).name
  end

  def order_present?
  	false
  	unless order_id.blank?
  		true
  	end
  end

end
