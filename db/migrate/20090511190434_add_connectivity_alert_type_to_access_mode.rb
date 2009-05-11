class AddConnectivityAlertTypeToAccessMode < ActiveRecord::Migration
  def self.up
  	at = AlertType.find(:first, :conditions => "alert_type = 'AccessMode'")
    ag = AlertGroup.find(:first, :conditions => {:group_type => "connectivity"})
    at.alert_groups << ag
  end

  def self.down
  end
end
