class MoveRelationshipToRolesUsersOptions < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :relationship
    add_column :roles_users_options, :relationship, :string
  end

  def self.down
    add_column :profiles, :relationship , :string
    remove_column :roles_users_options, :relationship
  end
end