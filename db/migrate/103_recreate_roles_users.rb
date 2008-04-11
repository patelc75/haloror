class RecreateRolesUsers < ActiveRecord::Migration
  def self.up
    drop_table :roles_users if
    ActiveRecord::Base.connection.tables.include?(:roles_users)
    
    create_table :roles_users, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id,          :integer
      t.column :role_id,          :integer
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end
  end

  def self.down
    drop_table :roles_users
  end
end
