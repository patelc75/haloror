class PopulateAlertType5 < ActiveRecord::Migration
  def self.up
    at = AlertType.find(:first, :conditions => "alert_type = 'DeviceAvailableAlert'")
    ag = AlertGroup.find(:first, :conditions => {:group_type => "connectivity"})
    at.alert_groups << ag
    
    at = AlertType.find(:first, :conditions => "alert_type = 'GatewayOnlineAlert'")
    ag = AlertGroup.find(:first, :conditions => {:group_type => "connectivity"})
    at.alert_groups << ag
  end

  def self.down
  end
end