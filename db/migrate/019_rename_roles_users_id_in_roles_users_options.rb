class RenameRolesUsersIdInRolesUsersOptions < ActiveRecord::Migration
  def self.up
    rename_column(:roles_users_options, :roles_users_id, :role_id)
  end

  def self.down
    rename_column(:roles_users_options, :role_id, :roles_users_id)
  end
end
