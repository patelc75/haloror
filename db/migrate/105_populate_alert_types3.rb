class PopulateAlertTypes3 < ActiveRecord::Migration
  def self.up
    execute "truncate table alert_types"
    execute "truncate table alert_groups_alert_types"
    # info
    ag = AlertGroup.find(:first, :conditions => {:group_type => "info"})
      
    (AlertType.create :alert_type => BatteryChargeComplete.class_name).alert_group << ag
    (AlertType.create :alert_type => BatteryUnplugged.class_name).alert_group << ag
    (AlertType.create :alert_type => BatteryPlugged.class_name).alert_group << ag
    (AlertType.create :alert_type => StrapFastened.class_name).alert_group << ag

    #    
    #    # high
    ag = AlertGroup.find(:first, :conditions => {:group_type => "high"})

    (AlertType.create :alert_type => StrapRemoved.class_name).alert_group << ag
    (AlertType.create :alert_type => BatteryCritical.class_name).alert_group << ag
    (AlertType.create :alert_type => DeviceUnavailableAlert.class_name).alert_group << ag
    (AlertType.create :alert_type => GatewayOfflineAlert.class_name).alert_group << ag    

    #    
    #    # critical
    ag = AlertGroup.find(:first, :conditions => {:group_type => "critical"})

    (AlertType.create :alert_type => Fall.class_name).alert_group << ag
    (AlertType.create :alert_type => Panic.class_name).alert_group << ag

    #    
    #    # battery
    ag = AlertGroup.find(:first, :conditions => {:group_type => "battery"})

    (AlertType.find(:first, :conditions => {:alert_type => BatteryChargeComplete.class_name})).alert_group << ag
    (AlertType.find(:first, :conditions => {:alert_type => BatteryUnplugged.class_name})).alert_group << ag
    (AlertType.find(:first, :conditions => {:alert_type => BatteryPlugged.class_name})).alert_group << ag
    (AlertType.find(:first, :conditions => {:alert_type => BatteryCritical.class_name})).alert_group << ag

    # connectivity
    ag = AlertGroup.find(:first, :conditions => {:group_type => "connectivity"})
    
    (AlertType.find(:first, :conditions => {:alert_type => StrapRemoved.class_name})).alert_group << ag
    (AlertType.find(:first, :conditions => {:alert_type => StrapFastened.class_name})).alert_group << ag
    (AlertType.find(:first, :conditions => {:alert_type => DeviceUnavailableAlert.class_name})).alert_group << ag
    (AlertType.find(:first, :conditions => {:alert_type => GatewayOfflineAlert.class_name})).alert_group << ag   
  end

  def self.down
  end
end
