class PopulateAlertTypes2 < ActiveRecord::Migration
  def self.up
    execute "truncate table alert_types"
    
    # info
    AlertType.create :alert_group_id => 1, :alert_type => BatteryChargeComplete.class_name
    AlertType.create :alert_group_id => 1, :alert_type => BatteryUnplugged.class_name
    AlertType.create :alert_group_id => 1, :alert_type => BatteryPlugged.class_name
    AlertType.create :alert_group_id => 1, :alert_type => StrapFastened.class_name
    
    # high
    AlertType.create :alert_group_id => 2, :alert_type => StrapRemoved.class_name
    AlertType.create :alert_group_id => 2, :alert_type => BatteryCritical.class_name
    AlertType.create :alert_group_id => 2, :alert_type => DeviceUnavailableAlert.class_name
    AlertType.create :alert_group_id => 2, :alert_type => OutageAlert.class_name
    
    # critical
    AlertType.create :alert_group_id => 3, :alert_type => Fall.class_name
    AlertType.create :alert_group_id => 3, :alert_type => Panic.class_name
    
    # battery
    AlertType.create :alert_group_id => 4, :alert_type => BatteryChargeComplete.class_name
    AlertType.create :alert_group_id => 4, :alert_type => BatteryUnplugged.class_name
    AlertType.create :alert_group_id => 4, :alert_type => BatteryPlugged.class_name
    AlertType.create :alert_group_id => 4, :alert_type => BatteryCritical.class_name
    
    # connectivity
    AlertType.create :alert_group_id => 5, :alert_type => StrapRemoved.class_name
    AlertType.create :alert_group_id => 5, :alert_type => StrapFastened.class_name
    AlertType.create :alert_group_id => 5, :alert_type => DeviceUnavailableAlert.class_name
    AlertType.create :alert_group_id => 5, :alert_type => OutageAlert.class_name
  end

  def self.down
  end
end
