class RenameRolesUsersIdToRolesUserIdInRolesUsersOptions < ActiveRecord::Migration
  def self.up
    rename_column :roles_users_options, :roles_users_id, :roles_user_id
  end

  def self.down
    rename_column :roles_users_options, :roles_user_id, :roles_users_id
  end
end
