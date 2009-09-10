class RemoveRecordsFromAlertGroups < ActiveRecord::Migration
  def self.up
  	AlertGroup.find_by_group_type('battery_outlet_status').destroy
  	AlertGroup.find_by_group_type('battery_level_status').destroy
  end

  def self.down
  	AlertGroup.create(:group_type => 'battery_outlet_status')
  	AlertGroup.create(:group_type => 'battery_level_status')
  end
end
