class AddDeprecatedToAlertTypes < ActiveRecord::Migration
  def self.up
  add_column :alert_types, :deprecated, :boolean
  end

  def self.down
  remove_column :alert_types, :deprecated
  end
end
