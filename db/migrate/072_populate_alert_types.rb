class PopulateAlertTypes < ActiveRecord::Migration
  def self.up
    # info
    AlertType.create :alert_groups_id => 1, :alert_type => 'battery_charge_complete'
    AlertType.create :alert_groups_id => 1, :alert_type => 'battery_unplugged'
    AlertType.create :alert_groups_id => 1, :alert_type => 'battery_plugged'
    AlertType.create :alert_groups_id => 1, :alert_type => 'strap_fastened'
    
    # high
    AlertType.create :alert_groups_id => 2, :alert_type => 'strap_removed'
    AlertType.create :alert_groups_id => 2, :alert_type => 'battery_critical'
    AlertType.create :alert_groups_id => 2, :alert_type => 'device_unavailable'
    AlertType.create :alert_groups_id => 2, :alert_type => 'outage'
    
    # critical
    AlertType.create :alert_groups_id => 3, :alert_type => 'fall'
    AlertType.create :alert_groups_id => 3, :alert_type => 'panic'
    
    # battery
    AlertType.create :alert_groups_id => 4, :alert_type => 'battery_charge_complete'
    AlertType.create :alert_groups_id => 4, :alert_type => 'battery_unplugged'
    AlertType.create :alert_groups_id => 4, :alert_type => 'battery_plugged'
    AlertType.create :alert_groups_id => 4, :alert_type => 'battery_critical'
    
    # connectivity
    AlertType.create :alert_groups_id => 5, :alert_type => 'strap_removed'
    AlertType.create :alert_groups_id => 5, :alert_type => 'strap_fastened'
    AlertType.create :alert_groups_id => 5, :alert_type => 'device_unavailable'
    AlertType.create :alert_groups_id => 5, :alert_type => 'outage'
  end

  def self.down
  end
end
