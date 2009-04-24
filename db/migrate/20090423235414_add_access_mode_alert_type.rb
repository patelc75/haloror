class AddAccessModeAlertType < ActiveRecord::Migration
  def self.up
    ag = AlertGroup.find(:first, :conditions => {:group_type => "high"})

    (AlertType.create :alert_type => AccessMode.class_name).alert_groups << ag
  end

  def self.down
  end
end
