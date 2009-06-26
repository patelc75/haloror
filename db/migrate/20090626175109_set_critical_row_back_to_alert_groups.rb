class SetCriticalRowBackToAlertGroups < ActiveRecord::Migration
# Run this migration on dev,idev,cdev and sdev on 27th june 2009 by chirag shah	
	
#  def self.up
#  	alert_group = AlertGroup.find_by_group_type('critical')
#  	if not alert_group  		
#  		sql = ActiveRecord::Base.connection()
#  		sql.execute "Insert into alert_groups(id,group_type,created_at,updated_at) values (3,'critical','#{Time.now.utc}','#{Time.now.utc}');"
#  		alert_group = AlertGroup.find_by_group_type('critical')
#  		@alerttypes = AlertType.find_all_by_alert_type ['Fall','Panic','GwAlarmButton','GwAlarmButtonTimeout']
#  		@alerttypes.each do |alert_type|
#  		alert_type.alert_groups << alert_group
#  		end
#  	end
  	
#  end

#  def self.down
#  end
end
