class UpdateAlertGroups < ActiveRecord::Migration
  def self.up
  	
  	caution_group = AlertGroup.find_by_group_type('caution')
    normal_group = AlertGroup.find_by_group_type('normal')
    
  	alert_type = AlertType.find_by_alert_type('DeviceAvailableAlert')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group and !alert_type.alert_groups.find_by_group_type('normal')
	alert_type.save
	 
	alert_type = AlertType.find_by_alert_type('GatewayOnlineAlert')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group and !alert_type.alert_groups.find_by_group_type('normal')
	alert_type.save
	
	
	alert_type = AlertType.find_by_alert_type('StrapOffAlert')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group and !alert_type.alert_groups.find_by_group_type('normal')
	alert_type.save
	
	
	alert_type = AlertType.find_by_alert_type('StrapOnAlert')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group and !alert_type.alert_groups.find_by_group_type('normal')
	alert_type.save
	
	alert_type = AlertType.find_by_alert_type('AccessMode')
	alert_type.alert_groups.delete(caution_group) if caution_group
	alert_type.alert_groups << normal_group if normal_group and !alert_type.alert_groups.find_by_group_type('normal')
	alert_type.save
	
	alert_type = AlertType.find_by_alert_type('BatteryReminder')
	alert_type.alert_groups << normal_group if normal_group and !alert_type.alert_groups.find_by_group_type('normal')
	alert_type.save
	
  end

  def self.down
  end
end
