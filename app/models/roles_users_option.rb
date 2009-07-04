class RolesUsersOption < ActiveRecord::Base
  acts_as_audited
  belongs_to :roles_user
end
