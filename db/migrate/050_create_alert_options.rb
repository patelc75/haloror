class CreateAlertOptions < ActiveRecord::Migration
  def self.up
    create_table :alert_options do |t|
      t.column :id, :primary_key, :null => false
      t.column :role_id, :integer
      t.column :alert_types_id, :integer
      t.column :phone_active, :boolean
      t.column :email_active, :boolean
      t.column :text_active, :boolean
      t.timestamps
    end
  end

  def self.down
    drop_table :alert_options
  end
end
