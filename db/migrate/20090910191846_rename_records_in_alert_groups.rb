class RenameRecordsInAlertGroups < ActiveRecord::Migration
  def self.up
  	@alert_group = AlertGroup.find_by_group_type('info')
  	@alert_group.update_attributes(:group_type => 'normal')
  	@alert_group = AlertGroup.find_by_group_type('high')
  	@alert_group.update_attributes(:group_type => 'caution')
  end

  def self.down
  	@alert_group = AlertGroup.find_by_group_type('normal')
  	@alert_group.update_attributes(:group_type => 'info')
  	@alert_group = AlertGroup.find_by_group_type('caution')
  	@alert_group.update_attributes(:group_type => 'high')
  end
end
