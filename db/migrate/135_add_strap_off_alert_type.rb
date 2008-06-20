class AddStrapOffAlertType < ActiveRecord::Migration
  def self.up
    AlertType.create :alert_type => StrapOffAlert.class_name     
  end

  def self.down
    AlertType.delete :conditions => "alert_type = 'StrapOffAlert'"
  end
end
