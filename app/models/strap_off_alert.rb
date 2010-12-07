class StrapOffAlert < ActiveRecord::Base
  belongs_to :device      
  belongs_to :user
  include Priority    
  
  DEVICE_CHEST_STRAP_TYPE = 'Halo Chest Strap'
  def self.job_detect_straps_off
    RAILS_DEFAULT_LOGGER.warn("StrapOffAlert.job_detect_straps_off running at #{Time.now}")
    
    ethernet_system_timeout = SystemTimeout.find_by_mode('ethernet')
    dialup_system_timeout   = SystemTimeout.find_by_mode('dialup')
    
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
    conds << "(id in (select device_id from access_mode_statuses where mode = 'ethernet') OR id not in (select device_id from access_mode_statuses))"
    conds << "id in (select ss.id from device_strap_status ss where is_fastened = 0 AND ss.updated_at < now() - interval '#{ethernet_system_timeout.strap_off_timeout_sec} seconds')"
    conds << "id in (select d.id from devices d where d.device_revision_id in (select device_revisions.id from device_revisions inner join (device_models inner join device_types on device_models.device_type_id = device_types.id) on device_revisions.device_model_id = device_models.id where device_types.device_type = 'Chest Strap'))"

    devices = Device.find(:all,
      :conditions => conds.join(' and '))

    devices.each do |device|
      
      process_device_strap_off(device)
    end
    
    # Do same thing for dialup
    conds = []
    conds << "id in (select device_id from access_mode_statuses where mode = 'dialup')"
    conds << "id in (select ss.id from device_strap_status ss where is_fastened = 0 AND ss.updated_at < now() - interval '#{dialup_system_timeout.strap_off_timeout_sec} seconds')"
    conds << "id in (select d.id from devices d where d.device_revision_id in (select device_revisions.id from device_revisions inner join (device_models inner join device_types on device_models.device_type_id = device_types.id) on device_revisions.device_model_id = device_models.id where device_types.device_type = 'Chest Strap'))"

    devices = Device.find(:all,
      :conditions => conds.join(' and '))

    devices.each do |device|
      
      process_device_strap_off(device)
    end
    
    true
  end

  # Wed Oct 27 01:17:41 IST 2010
  #   Error on sdev: /home/web/haloror/app/models/strap_off_alert.rb:58: warning: Object#id will be deprecated; use Object#object_id
  # FIXME: assign user object, but needs testing before this code can be changed
  #   left intact without any change, for now
  # 
  #  Wed Dec  8 02:28:20 IST 2010, ramonrails
  #   * changed to assigning an object instead of object.id
  #   * log file is written on each object.id access at www
  def before_save
    self.user = device.users.first
  end
    
  def after_save
    if number_attempts == MAX_ATTEMPTS_BEFORE_NOTIFICATION_STRAP_OFF
      Event.create_event(user.id, StrapOffAlert.class_name, id, created_at)
      CriticalMailer.deliver_non_critical_caregiver_email(self, user)  
      CriticalMailer.deliver_non_critical_caregiver_text(self, user)        
    end
  end

  def email_body
    user.nil? ? user_info = "the myHalo user" : user_info = "(#{user.id}) #{user.name}"                                    
    "Hello,\n\nOn #{UtilityHelper.format_datetime(created_at,user)}, we detected that " + user_info + " has their chest strap off\n\n" +
    "- Halo Staff"  
  end
    
  def to_s
    user.nil? ? user_info = "" : user_info = " for #{user.name} (#{user.id})"            
    "Strap has been off " + user_info
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