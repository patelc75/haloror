class PopulateAlertTypes4 < ActiveRecord::Migration
  def self.up
    ag = AlertGroup.find(:first, :conditions => {:group_type => "high"})

    (AlertType.create :alert_type => DeviceAvailableAlert.class_name).alert_groups << ag
    (AlertType.create :alert_type => GatewayOnlineAlert.class_name).alert_groups << ag    
  end

  def self.down
  end
end
