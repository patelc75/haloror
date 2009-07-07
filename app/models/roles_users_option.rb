class RolesUsersOption < ActiveRecord::Base
  acts_as_audited
  belongs_to :roles_user
  
  def owner_user # for auditing
    self.roles_user.user
  rescue
    nil
  end
  
end
