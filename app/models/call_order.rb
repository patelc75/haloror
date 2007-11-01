class CallOrder < ActiveRecord::Base
  belongs_to :user  
  
  #the following line creates an alias for the association
  #belongs_to :strapwearer,  #,:class_name => "User", :foreign_key => "user_id" 
  
  belongs_to :caregiver
  
  acts_as_list :scope => :user
end
