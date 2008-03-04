class MgmtQuery < ActiveRecord::Base

  MINUTES_INTERVAL = 15

  belongs_to :mgmt_cmd
  belongs_to :device

  # Each user's wireless gateway queries the server every MINUTES_INTERVAL
  # minutes. We need to detect the devices that have not connected in
  # a while and create notifications of outages after a certain number
  # of failures.
  def MgmtQuery.job_detect_disconnected_users
    ## Find devices that were previously signaling errors but have
    ## come back online.
    sql = 'update outage_alerts set reconnected_at = now() where reconnected_at is null and device_id in ' <<
          " (select id from device_latest_queries where updated_at > now() - interval '#{MINUTES_INTERVAL} minutes') "
    MgmtQuery.connection.execute(sql)

    sql = 'select d.* ' <<
      "  from devices d " <<
      "  left outer join device_latest_queries on device_latest_queries.id = d.id and device_latest_queries.updated_at > now() - interval '#{MINUTES_INTERVAL} minutes' " <<
      " where device_latest_queries.id is null "

    Device.find_by_sql(sql).each do |device|
      begin
        MgmtQuery.process_alert(device)
      rescue Exception => e
        logger.fatal("Error processing outage alert for device #{device.inspect}: #{e}")
        raise e if ENV['RAILS_ENV'] == "development"
      end
    end
  end
  

  private
  def MgmtQuery.process_alert(device)
    alert = OutageAlert.find(:first,
                             :order => 'created_at desc',
                             :conditions => ['reconnected_at is null and device_id = ?', device.id])

    if alert
      alert.number_attempts += 1
      alert.save!
    else
      alert = OutageAlert.new
      alert.device = device
      alert.save!
    end
  end

end
