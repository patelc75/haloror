class AddPriorityToDeviceUnavailableAlerts < ActiveRecord::Migration
  def self.up
    add_column :device_unavailable_alerts, :priority, :integer
  end

  def self.down
    remove_column :device_unavailable_alerts, :integer
  end
end
