class RenameOutageAlerts < ActiveRecord::Migration

  def self.up
    execute "alter table outage_alerts rename to gateway_offline_alerts"
  end

  def self.down
    execute "alter table gateway_offline_alerts rename to outage_alerts"
  end

end
