class AddStrapOffAlertTypeToAlertGroups < ActiveRecord::Migration
  def self.up
    at = AlertType.find(:first, :conditions => "alert_type = 'StrapOffAlert'")
    ag = AlertGroup.find(:first, :conditions => {:group_type => "high"})
    at.alert_groups << ag
    ag = AlertGroup.find(:first, :conditions => {:group_type => "connectivity"})
    at.alert_groups << ag
  end

  def self.down
  end
end
