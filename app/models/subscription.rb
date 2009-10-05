class Subscription < ActiveRecord::Base
	
	belongs_to :senior, :class_name => "User", :foreign_key => "senior_user_id"
	belongs_to :subscriber, :class_name => "User", :foreign_key => "subscriber_user_id"
	
end
