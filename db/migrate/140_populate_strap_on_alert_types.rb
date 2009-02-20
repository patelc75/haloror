class PopulateStrapOnAlertTypes < ActiveRecord::Migration
  def self.up
    at = AlertType.create :alert_type => StrapOnAlert.class_name     

    if(AlertType.columns_hash.has_key?("alert_group_id"))
	  ag = AlertGroup.find(:first, :conditions => {:group_type => "high"})
	  at.alert_groups << ag
	  ag = AlertGroup.find(:first, :conditions => {:group_type => "connectivity"})
	  at.alert_groups << ag
	end
  end

  def self.down
    AlertType.delete :conditions => "alert_type = 'StrapOnAlert'"
  end
end
