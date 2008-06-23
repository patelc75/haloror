class StrapOffAlert < DeviceAlert
 set_table_name "strap_off_alerts"
 DEVICE_CHEST_STRAP_TYPE = 'Halo Chest Strap'
  def self.job_detect_straps_off

    conds = []
    conds << "reconnected_at is null"
    conds << "device_id in (select d.id from devices d where d.device_type = '#{DEVICE_CHEST_STRAP_TYPE}')"
    conds << "device_id in (select status.id from device_strap_status status where is_fastened > 0)"
    
    alerts = StrapOffAlert.find(:all,
      :conditions => conds.join(' and '))
    alerts.each do |alert|
        soa = StrapOnAlert.new(:device_id => alert.device_id)
        soa.save!
        alert.reconnected_at = Time.now
        alert.save!
    end

    conds = []
    conds << "id in (select ss.id from device_strap_status ss where is_fastened = 0 AND ss.updated_at < now() - interval '#{STRAP_OFF_TIMEOUT} minutes')"
    conds << "id in (select d.id from devices d where d.device_type = '#{DEVICE_CHEST_STRAP_TYPE}')"

    devices = Device.find(:all,
      :conditions => conds.join(' and '))

    devices.each do |device|
      
     process_device_strap_off(device)
    end
    ActiveRecord::Base.verify_active_connections!()
    true
  end
  
  def after_save
    if number_attempts == MAX_ATTEMPTS_BEFORE_NOTIFICATION_STRAP_OFF
      device.users.each do |user|
        Event.create(:user_id => user.id, 
                   :event_type => StrapOffAlert.class_name, 
                   :event_id => id, 
                   :timestamp => created_at || Time.now)
        CriticalMailer.deliver_strap_off_notification(self, user)
      end
    end
  end
  private
  def self.process_device_strap_off(device)
    alert = StrapOffAlert.find(:first,
      :order => 'created_at desc',
      :conditions => ['reconnected_at is null and device_id = ?', device.id])

    if alert
      alert.number_attempts += 1
      alert.save!
    else
      alert = StrapOffAlert.new
      alert.device = device
      alert.save!
    end
  end
end