class RemoveNewUserRoleAndAssociations < ActiveRecord::Migration
  def self.up
    new_user_role = Role.find_by_name('new_user')
    if(new_user_role)
      roles_users = RolesUser.find(:all, :conditions => "role_id = #{new_user_role.id}")
      RolesUser.delete(roles_users)
      Role.delete(new_user_role)
    end
  end

  def self.down
  end
end
