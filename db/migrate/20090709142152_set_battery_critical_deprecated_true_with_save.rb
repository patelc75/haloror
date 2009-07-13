class SetBatteryCriticalDeprecatedTrueWithSave < ActiveRecord::Migration
  def self.up
    alert_type = AlertType.find_by_alert_type('BatteryCritical')
    alert_type.update_attributes(:deprecated => true)
    alert_type.save
  end

  def self.down
  end
end
