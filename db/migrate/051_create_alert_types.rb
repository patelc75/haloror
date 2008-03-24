class CreateAlertTypes < ActiveRecord::Migration
  def self.up
    create_table :alert_types do |t|
      t.column :id, :primary_key, :null => false
      t.column :alert_groups_id, :integer
      t.column :alert_type, :string
      t.column :phone_active, :boolean
      t.column :email_active, :boolean
      t.column :text_active, :boolean
      t.timestamps
    end
  end

  def self.down
    drop_table :alert_types
  end
end
