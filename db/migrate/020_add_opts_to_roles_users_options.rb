class AddOptsToRolesUsersOptions < ActiveRecord::Migration
  def self.up
    add_column :roles_users_options, :active, :boolean
    add_column :roles_users_options, :phone_active, :boolean
    add_column :roles_users_options, :email_active, :boolean
    add_column :roles_users_options, :text_active, :boolean
    add_column :roles_users_options, :position, :integer
  end

  def self.down
    remove_column :roles_users_options, :active
    remove_column :roles_users_options, :phone_active
    remove_column :roles_users_options, :email_active
    remove_column :roles_users_options, :text_active
    remove_column :roles_users_options, :position_active
  end
end
