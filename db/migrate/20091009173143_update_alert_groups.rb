class UpdateAlertGroups < ActiveRecord::Migration
  def self.up
  	
  	alert_type = AlertType.find_by_alert_type('DeviceAvailableAlert')
    caution_group = AlertGroup.find_by_group_type('caution')
    normal_group = AlertGroup.find_by_group_type('normal')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group
	alert_type.save
	 
	alert_type = AlertType.find_by_alert_type('GatewayOnlineAlert')
    caution_group = AlertGroup.find_by_group_type('caution')
    normal_group = AlertGroup.find_by_group_type('normal')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group
	alert_type.save
	
	
	alert_type = AlertType.find_by_alert_type('StrapOffAlert')
    caution_group = AlertGroup.find_by_group_type('caution')
    normal_group = AlertGroup.find_by_group_type('normal')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group
	alert_type.save
	
	
	alert_type = AlertType.find_by_alert_type('StrapOnAlert')
    caution_group = AlertGroup.find_by_group_type('caution')
    normal_group = AlertGroup.find_by_group_type('normal')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group
	alert_type.save
	
	alert_type = AlertType.find_by_alert_type('AccessMode')
    caution_group = AlertGroup.find_by_group_type('caution')
    normal_group = AlertGroup.find_by_group_type('normal')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group
	alert_type.save
	
	alert_type = AlertType.find_by_alert_type('BatteryReminder')
    normal_group = AlertGroup.find_by_group_type('normal')
	alert_type.alert_groups << normal_group if normal_group
	alert_type.save
	
	
	
#    alert_type.alert_groups << alert_group if alert_group
#    alert_type.save!
#  end
#
#  def self.down
#  end

  end

  def self.down
  end
end
