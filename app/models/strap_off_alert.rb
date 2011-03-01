class StrapOffAlert < ActiveRecord::Base
  belongs_to :device      
  belongs_to :user
  include Priority    
  
  DEVICE_CHEST_STRAP_TYPE = 'Halo Chest Strap'
  def self.job_detect_straps_off
    RAILS_DEFAULT_LOGGER.warn("StrapOffAlert.job_detect_straps_off running at #{Time.now}")
    
    conds = []
    conds << "reconnected_at IS NULL"
    conds << "device_id IN (SELECT id from devices where serial_number LIKE 'H1%')"
    conds << "device_id IN (SELECT status.id FROM device_strap_status status WHERE is_fastened > 0)"
    #conds << "device_id IN (SELECT d.id FROM devices d WHERE d.device_revision_id IN (SELECT device_revisions.id FROM device_revisions INNER JOIN (device_models INNER JOIN device_types ON device_models.device_type_id = device_types.id) ON device_revisions.device_model_id = device_models.id WHERE device_types.device_type = 'Chest Strap'))"
    
    alerts = StrapOffAlert.find(:all, :conditions => conds.join(' and '))
    
    alerts.each do |alert|
      soa = StrapOnAlert.new(:device_id => alert.device_id)
      soa.save!
      alert.reconnected_at = Time.now
      alert.save!
    end
 
    ['ethernet', 'dialup'].each do |_mode|
      conds = []
      conds << "(id IN (SELECT device_id FROM access_mode_statuses WHERE mode = '#{_mode}') OR id NOT IN (SELECT device_id FROM access_mode_statuses))"
      conds << "id IN (SELECT ss.id FROM device_strap_status ss WHERE is_fastened = 0 AND ss.updated_at < now() - interval '#{SystemTimeout.send(_mode.to_sym).strap_off_timeout_sec} seconds')"
      conds << "id IN (SELECT id from devices where serial_number LIKE 'H1%')"     
      conds << "id IN ( SELECT d.device_id FROM devices_users d )" #  exclude devices with no mapped users  
      # 
      #  Tue Feb 22 02:27:56 IST 2011, ramonrails
      #   * Can be ruby code with single SQL query
      #   * TODO: change to ruby code. Has same performance
      #    Device.chest_straps.ethernets.all( :conditions => { :id => DeviceStrapStatus.strapped_off.updated_before( SystemTimeout.dialup.strap_off_timeout_sec ).all( :select => :id).collect(&:id) })
      devices = Device.find(:all, :conditions => conds.join(' AND '))
      devices.each { |device| process_device_strap_off(device) }
    end   
    
    true
  end

  # Wed Oct 27 01:17:41 IST 2010
  #   Error ON sdev: /home/web/haloror/app/models/strap_off_alert.rb:58: warning: Object#id will be deprecated; use Object#object_id
  # FIXME: assign user object, but needs testing before this code can be changed
  #   left intact without any change, for now
  # 
  #  Wed Dec  8 02:28:20 IST 2010, ramonrails
  #   * changed to assigning an object instead of object.id
  #   * log file is written ON each object.id access at www
  def before_save
    self.user = device.users.first
    # 
    #  Tue Feb 22 01:35:46 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4203
    RAILS_DEFAULT_LOGGER.warn("#{Time.now}: #{device.inspect} does not have any user") if user.blank?
  end
    
  def after_save
    # 
    #  Tue Feb 22 01:36:07 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4203
    #   * avoid any errors due to missing user
    #   * we already logged the missing user error
    if (number_attempts == MAX_ATTEMPTS_BEFORE_NOTIFICATION_STRAP_OFF) && !user.blank?
      Event.create_event( user.id, StrapOffAlert.class_name, id, created_at)
      CriticalMailer.deliver_non_critical_caregiver_email( self, user)
      CriticalMailer.deliver_non_critical_caregiver_text( self, user)
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