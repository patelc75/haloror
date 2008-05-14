class CreateBatteryAlertTypes < ActiveRecord::Migration
  def self.up
#Not needed because it is re-populated in migration # 105
#Commenting out because it causes an error when running migrations#    AlertType.create :alert_group_id => 6, :type => BatteryPlugged.class_name
#    AlertType.create :alert_group_id => 6, :type => BatteryUnplugged.class_name
#    AlertType.create :alert_group_id => 7, :type => BatteryChargeComplete.class_name
#    AlertType.create :alert_group_id => 7, :type => BatteryCritical.class_name
  end

  def self.down
  end
end
