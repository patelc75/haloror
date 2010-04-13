class UserIntakesUser < ActiveRecord::Base
  belongs_to :user_intake
  belongs_to :user
  # belongs_to :senior, :foreign_key => "user_id", :class_name => "Senior"
  # belongs_to :subscriber, :foreign_key => "user_id", :class_name => "Subscriber"
  # belongs_to :caregiver, :foreign_key => "user_id", :class_name => "Caregiver"
end
