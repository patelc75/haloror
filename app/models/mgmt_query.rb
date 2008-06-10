class MgmtQuery < ActiveRecord::Base

  #MINUTES_INTERVAL = 1

  belongs_to :mgmt_cmd
  belongs_to :device

  # Each user's wireless gateway queries the server every
  # MINUTES_INTERVAL minutes. We need to detect the devices that have
  # not connected in a while and create notifications of outages after
  # a certain number of failures. This outage is called an Outage
  # Alert and triggers a Gateway Offline event
  def MgmtQuery.job_detect_disconnected_users
    ActiveRecord::Base.logger.debug("MgmtQuery.job_detect_disconnected_users running at #{Time.now}")

    ## Find devices that were previously signaling errors but have
    ## come back online. Trigger a "Reconnect" event for these
    ## devices. In practice, there should be very few of these alerts
    ## so we process them one by one as the devices come back online.
    reconnected = Device.find(:all,
                              :conditions => 'id in (select device_id from gateway_offline_alerts where reconnected_at is null and device_id in ' <<
                              " (select id from device_latest_queries where updated_at > now() - interval '#{GATEWAY_OFFLINE_TIMEOUT} minutes'))")
    reconnected.each do |device|
      Device.transaction do
        GatewayOnlineAlert.create(:device => device)

        GatewayOfflineAlert.find(:all, 
                                 :conditions => ['device_id = ? and reconnected_at is null', device.id]).each do |alert|
          alert.reconnected_at = Time.now
          alert.save!
        end
      end
    end

    devices = Device.find(:all,
                          :conditions => "id in (select dlq.id from device_latest_queries dlq where dlq.updated_at < now() - interval '#{GATEWAY_OFFLINE_TIMEOUT} minutes')")
    devices.each do |device|
      begin
        MgmtQuery.process_alert(device)
      rescue Exception => e
        logger.fatal("Error processing outage alert for device #{device.inspect}: #{e}")
        raise e if ENV['RAILS_ENV'] == "development" || ENV['RAILS_ENV'] == "test"
      end
    end
    ActiveRecord::Base.verify_active_connections!()
  end
  

  private
  def MgmtQuery.process_alert(device)
    alert = GatewayOfflineAlert.find(:first,
                             :order => 'created_at desc',
                             :conditions => ['reconnected_at is null and device_id = ?', device.id])

    if alert
      alert.number_attempts += 1
      alert.save!
    else
      alert = GatewayOfflineAlert.new
      alert.device = device
      alert.save!
    end
  end

end
