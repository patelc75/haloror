class StrapOffAlert < DeviceAlert
 set_table_name "strap_off_alerts"
  def self.job_detect_straps_off
    select = "select id from device_strap_status where updated_at < now() - interval '#{STRAP_OFF_TIMEOUT} minutes' AND is_fastened = 0"
    StrapOffAlert.connection.select_all(select).collect do |row|
      RAILS_DEFAULT_LOGGER.warn("***********#{row}")
      alert = StrapOffAlert.find(:first,
                               :order => 'created_at desc',
                               :conditions => ['device_id = ?', row['id']])
      if alert
        alert.number_attempts += 1
        alert.save!
      else
        alert = StrapOffAlert.new(:device_id => row['id'], :created_at => Time.now)
        alert.save!
      end
    end
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
end