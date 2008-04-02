class PopulateAlertTypes < ActiveRecord::Migration
  def self.up
    # info
    AlertType.create :alert_groups_id => 1, :type => 'battery_charge_complete'
    AlertType.create :alert_groups_id => 1, :type => 'battery_unplugged'
    AlertType.create :alert_groups_id => 1, :type => 'battery_plugged'
    AlertType.create :alert_groups_id => 1, :type => 'strap_fastened'
    
    # high
    AlertType.create :alert_groups_id => 2, :type => 'strap_removed'
    AlertType.create :alert_groups_id => 2, :type => 'battery_critical'
    AlertType.create :alert_groups_id => 2, :type => 'device_unavailable'
    AlertType.create :alert_groups_id => 2, :type => 'outage'
    
    # critical
    AlertType.create :alert_groups_id => 3, :type => 'fall'
    AlertType.create :alert_groups_id => 3, :type => 'panic'
    
    # battery
    AlertType.create :alert_groups_id => 4, :type => 'battery_charge_complete'
    AlertType.create :alert_groups_id => 4, :type => 'battery_unplugged'
    AlertType.create :alert_groups_id => 4, :type => 'battery_plugged'
    AlertType.create :alert_groups_id => 4, :type => 'battery_critical'
    
    # connectivity
    AlertType.create :alert_groups_id => 5, :type => 'strap_removed'
    AlertType.create :alert_groups_id => 5, :type => 'strap_fastened'
    AlertType.create :alert_groups_id => 5, :type => 'device_unavailable'
    AlertType.create :alert_groups_id => 5, :type => 'outage'
  end

  def self.down
  end
end
