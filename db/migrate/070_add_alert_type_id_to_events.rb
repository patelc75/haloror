class AddAlertTypeIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :alert_type_id, :integer
  end

  def self.down
    remove_column :events, :alert_type_id
  end
end
