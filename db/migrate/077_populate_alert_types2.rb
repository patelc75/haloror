class PopulateAlertTypes2 < ActiveRecord::Migration
  def self.up
    execute "truncate table alert_types"
    
    # info
    AlertType.create :alert_group_id => 1, :type => BatteryChargeComplete.class_name
    AlertType.create :alert_group_id => 1, :type => BatteryUnplugged.class_name
    AlertType.create :alert_group_id => 1, :type => BatteryPlugged.class_name
    AlertType.create :alert_group_id => 1, :type => StrapFastened.class_name
    
    # high
    AlertType.create :alert_group_id => 2, :type => StrapRemoved.class_name
    AlertType.create :alert_group_id => 2, :type => BatteryCritical.class_name
    AlertType.create :alert_group_id => 2, :type => DeviceUnavailableAlert.class_name
    AlertType.create :alert_group_id => 2, :type => OutageAlert.class_name
    
    # critical
    AlertType.create :alert_group_id => 3, :type => Fall.class_name
    AlertType.create :alert_group_id => 3, :type => Panic.class_name
    
    # battery
    AlertType.create :alert_group_id => 4, :type => BatteryChargeComplete.class_name
    AlertType.create :alert_group_id => 4, :type => BatteryUnplugged.class_name
    AlertType.create :alert_group_id => 4, :type => BatteryPlugged.class_name
    AlertType.create :alert_group_id => 4, :type => BatteryCritical.class_name
    
    # connectivity
    AlertType.create :alert_group_id => 5, :type => StrapRemoved.class_name
    AlertType.create :alert_group_id => 5, :type => StrapFastened.class_name
    AlertType.create :alert_group_id => 5, :type => DeviceUnavailableAlert.class_name
    AlertType.create :alert_group_id => 5, :type => OutageAlert.class_name
  end

  def self.down
  end
end
