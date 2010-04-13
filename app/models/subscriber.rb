class Subscriber # < User
#   has_many :user_intakes_users, :foreign_key => "user_id", :dependent => :destroy
#   has_many :user_intakes, :through => :user_intakes_users
#   
#   # override the validations
#   def password_required?
#     false
#   end
end