class RolesUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  has_one :roles_users_option
  has_many :alert_options
end
