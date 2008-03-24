class RolesUsersOption < ActiveRecord::Base
  belongs_to :roles_user
  has_many :alerts
end
