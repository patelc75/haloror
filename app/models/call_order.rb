class CallOrder < ActiveRecord::Base
  belongs_to :user  
  
  #the following line creates an alias for the association
  #belongs_to :strapwearer,  #,:class_name => "User", :foreign_key => "user_id" 
  
  #before single table inheritance
  #belongs_to :caregiver
  
  #after single table inheritance
  belongs_to :caregiver, :class_name => "User", :foreign_key => "caregiver_id"
  
  acts_as_list :scope => :user
end
