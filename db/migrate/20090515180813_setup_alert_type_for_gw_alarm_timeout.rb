class SetupAlertTypeForGwAlarmTimeout < ActiveRecord::Migration
  def self.up
    alert_type = AlertType.new(:alert_type => 'GwAlarmButtonTimeout')
    alert_type.save!
    alert_group = AlertGroup.find_by_group_type('critical')
    alert_type.alert_groups << alert_group if alert_group
    alert_type.save!	
  end

  def self.down
  end
end
