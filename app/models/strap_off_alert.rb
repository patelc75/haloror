class StrapOffAlert < DeviceAlert
  set_table_name "strap_off_alerts"
  DEVICE_CHEST_STRAP_TYPE = 'Halo Chest Strap'
  def self.job_detect_straps_off
    RAILS_DEFAULT_LOGGER.warn("StrapOffAlert.job_detect_straps_off running at #{Time.now}")
    conds = []
    conds << "reconnected_at is null"
    conds << "device_id in (select d.id from devices d where d.device_revision_id in (Select device_revisions.id from device_revisions inner join (device_models inner join device_types on device_models.device_type_id = device_types.id) on device_revisions.device_model_id = device_models.id Where device_types.device_type = 'Chest Strap'))"
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
    conds << "id in (select d.id from devices d where d.device_revision_id in (Select device_revisions.id from device_revisions inner join (device_models inner join device_types on device_models.device_type_id = device_types.id) on device_revisions.device_model_id = device_models.id Where device_types.device_type = 'Chest Strap'))"

    devices = Device.find(:all,
      :conditions => conds.join(' and '))

    devices.each do |device|
      
      process_device_strap_off(device)
    end
    true
  end
  
  def after_save
    if number_attempts == MAX_ATTEMPTS_BEFORE_NOTIFICATION_STRAP_OFF
      device.users.each do |user|
        Event.create_event(user.id, StrapOffAlert.class_name, id, created_at)
        CriticalMailer.deliver_background_task_notification(self, user)
      end
    end
  end
  
  def to_s
    "Strap has been off for at least #{STRAP_OFF_TIMEOUT} minutes"
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