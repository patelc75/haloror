class AddPriorityToDeviceAvailableAlerts < ActiveRecord::Migration
  def self.up
    add_column :device_available_alerts, :priority, :integer
  end

  def self.down
    remove_column :device_available_alerts, :integer
  end
end
