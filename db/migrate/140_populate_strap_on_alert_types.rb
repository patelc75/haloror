class PopulateStrapOnAlertTypes < ActiveRecord::Migration
  def self.up
    at = AlertType.create :alert_type => StrapOnAlert.class_name     

    ag = AlertGroup.find(:first, :conditions => {:group_type => "high"})
    at.alert_groups << ag
    ag = AlertGroup.find(:first, :conditions => {:group_type => "connectivity"})
    at.alert_groups << ag
  end

  def self.down
    AlertType.delete :conditions => "alert_type = 'StrapOnAlert'"
  end
end
