class AddUserIdToRolesUsersOptions < ActiveRecord::Migration
  def self.up
    add_column :roles_users_options, :user_id, :integer
  end

  def self.down
    remove_column :roles_users_options, :user_id
  end
end
