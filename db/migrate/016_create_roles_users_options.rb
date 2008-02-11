class CreateRolesUsersOptions < ActiveRecord::Migration
  def self.up
    create_table :roles_users_options do |t|
      t.column :roles_users_id,          :integer
      t.column :removed,          :boolean, :default => 0
    end
  end

  def self.down
    drop_table :roles_users_options
  end
end
