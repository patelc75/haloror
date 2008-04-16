class CreateAlertGroupsAlertTypes < ActiveRecord::Migration
  def self.up
    create_table :alert_groups_alert_types, :id => false, :force => true do |t|
      #t.column :id, :primary_key, :null => false
      t.column :alert_group_id,          :integer
      t.column :alert_type_id,          :integer
      #t.column :created_at,       :datetime
      #t.column :updated_at,       :datetime
    end
    
    drop_table :alerts if
    ActiveRecord::Base.connection.tables.include?(:alerts)
    
    remove_column :alert_types, :alert_group_id if
    ActiveRecord::Base.connection.tables.include?(:alert_types)
  end

  def self.down
    drop_table :alert_groups_alert_types
  end
end
