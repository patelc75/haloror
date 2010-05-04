class Caregiver # < User
#   has_many :user_intakes_users, :foreign_key => "user_id", :dependent => :destroy
#   has_many :user_intakes, :through => :user_intakes_users
#   attr_accessor :is_keyholder, :phone_active, :email_active, :text_active, :active, :position
# 
#   # override the validations
#   def password_required?
#     false
#   end
end