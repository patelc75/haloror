class InitializeReconnectedAt < ActiveRecord::Migration
  def self.up
    DeviceLatestQuery.find(:all).each do |dlq|
      gwoffline = GatewayOfflineAlert.find(:first, :order => "updated_at desc", :conditions => ['device_id = ?', dlq.id])
      if !gwoffline.nil?
        dlq.reconnected_at = gwoffline.reconnected_at
      else
        dlq.reconnected_at = Time.now
      end
      dlq.save
    end    
  end

  def self.down
  end
end
