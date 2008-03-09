class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.column :id, :primary_key, :null => false
      t.column :roles_users_option_id, :integer
      t.column :event_kind, :string
      t.column :email_active, :boolean
      t.column :phone_active, :boolean
      t.column :text_active, :boolean
      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
