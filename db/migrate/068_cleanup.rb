class Cleanup < ActiveRecord::Migration
  def self.up
    drop_table :alerts
    
    remove_column :events, :level
  end

  def self.down
    create_table :alerts do |t|
      t.column :id, :primary_key, :null => false
      t.column :roles_users_option_id, :integer
      t.column :event_kind, :string
      t.column :email_active, :boolean
      t.column :phone_active, :boolean
      t.column :text_active, :boolean
      t.timestamps
    end
    
    add_column :events, :level, :string
  end
end
