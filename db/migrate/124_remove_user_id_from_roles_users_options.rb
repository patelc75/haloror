class RemoveUserIdFromRolesUsersOptions < ActiveRecord::Migration
  def self.up
    remove_column :roles_users_options, :user_id
  end

  def self.down
    add_column :roles_users_options, :user_id, :integer
  end
end
