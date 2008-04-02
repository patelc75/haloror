class CreateBatteryAlertTypes < ActiveRecord::Migration
  def self.up
    AlertType.create :alert_group_id => 6, :alert_type => BatteryPlugged.class_name
    AlertType.create :alert_group_id => 6, :alert_type => BatteryUnplugged.class_name
    AlertType.create :alert_group_id => 7, :alert_type => BatteryChargeComplete.class_name
    AlertType.create :alert_group_id => 7, :alert_type => BatteryCritical.class_name
  end

  def self.down
  end
end
