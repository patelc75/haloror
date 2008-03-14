class CreateAlertGroups < ActiveRecord::Migration
  def self.up
    create_table :alert_groups do |t|
      t.column :id, :primary_key, :null => false
      t.column :magnitude, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :alert_groups
  end
end
