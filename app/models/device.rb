class Device < ActiveRecord::Base
  # ====================================
  # = # attributes ------------------- =
  # ====================================
  
  attr_accessor :attr_last_dial_up_status, :attr_last_dial_up_alert
  
  # ======================================
  # = # relationships ------------------ =
  # ======================================
  
  belongs_to :device_revision
  belongs_to :work_order

  has_one :access_mode_status # most recent status?
  has_one :device_info

  has_many :access_modes
  has_many :batteries
  has_many :battery_charge_completes
  has_many :battery_criticals
  has_many :battery_pluggeds
  has_many :battery_unpluggeds
  has_many :dial_up_alerts
  has_many :dial_up_statuses
  has_many :device_available_alerts
  has_many :device_unavailable_alerts
  has_many :falls
  has_many :gateway_offline_alerts
  has_many :gateway_online_alerts
  has_many :mgmt_cmds
  has_many :mgmt_queries
  has_many :panics
  has_many :strap_fasteneds
  has_many :strap_removeds

  has_and_belongs_to_many :kits
  has_and_belongs_to_many :users

  # ========================================
  # = # validations ---------------------- =
  # ========================================
  
  validates_presence_of :serial_number, :message => "Serial number must be present for device"
  validates_length_of :serial_number, :is => 10, :message => "Length must be 10 characters"
  validates_uniqueness_of :serial_number, :case_sensitive => false, :on => :create, :message => "Serial number is not unique"

  # ===================================
  # = named scopes, searches, filters =
  # ===================================

  # Usage:
  #   Device.gateways
  #   Device.gateways( "442")
  #   Device.chest_straps
  #   User.last.devices.gateways.first
  # WARNING: TODO: re-confirm the device identifications here
  { :gateways => "H2", :chest_straps => "H1", :belt_clips => "H5", :kits => "H4" }.each do |key, value|
    #
    # scopes
    named_scope key, lambda {|*args| { :conditions => ["devices.serial_number LIKE ? AND devices.serial_number LIKE ?", "#{value}%", "%#{args.flatten.first}%"] }}
  end
    
  # Usage:
  #   Device.where_status "Installed"
  named_scope :where_status, lambda {|*_args| { :include => :users, :conditions => ["users.status = ?", _args.flatten.first.to_s] }}
  
  # Usage:
  #   Device.of_users( [])
  named_scope :where_user_ids, lambda {|*_args| {:include => :users, :conditions => ["users.id IN (?)", _args.flatten ] }}

  # Usage:
  #   Device.dialups
  #   Device.ethernets
  [:dialups, :ethernets].each do |_mode|
    named_scope _mode, :include => :access_mode_status, :conditions => ["access_mode_statuses.mode = ?", "#{_mode.to_s.singularize}"]
  end

  # =============
  # = callbacks =
  # =============
  
  # assign device_type if not already assigned
  def before_save
    if device_type.blank?
      case serial_number[0..1]
      when "H1"; set_chest_strap_type
      when "H2"; set_gateway_type
      when "H5"; set_chest_strap_type
      end
    end
    true
  end

  # =================
  # = class methods =
  # =================
  
  # find if a device is available and ready to get linked to a user
  # Usage:
  #   Device.available?( 243)
  #   Device.available?( "H1000000442")
  #   Device.available?( device_object)
  #   Device.available?( device_object, User.last) => Device is either assigned to given user, or free to assign
  def self.available?( _serial, _user = nil)
    _device = Device.fetch_device( _serial)
    #
    # * device was found in database
    # * device is not assigned to any user yet
    # * QUESTION: do we want to check "active"?
    !_device.blank? && (_device.users - [_user]).blank? # && _device.active
  end

  def self.registered?( _serial, _user = nil)
    if (_device = Device.fetch_device( _serial))
      if _user.blank?
        !_device.users.blank? # registered to someone
      else
        _device.users.include?( _user) # registered to given user
      end
    else
      # QUESTION: shall we treat missing devices as "assigned"? to keep business logic bug free
      true # missing? consider it registered
    end
  end
  
  def self.unregister( _ids = "")
    # assumption: all ids are numeric values
    # WARNING: any non-number within ids will cause id be recognized as ZERO
    _ids = if _ids.is_a?( String)
      _ids.parse_integer_ranges
    elsif _ids.is_a?( Array)
      _ids.flatten
    elsif _ids.to_i > 0
      _ids
    end
    devices = Device.all( :conditions => { :id => _ids }) # parse ranges like "1-3, 5, 7-9, 10, 17, 19"
    devices.each do |device|

      device.users.each do |user|
        #user.caregivers.each do |caregiver|
          #UserMailer.deliver_user_unregistered( caregiver, user) # New email notification to caregivers indicating service stopped
          #user.log("Email sent to caregiver (#{caregiver.name}): User (#{user.name}) un-registered.")
        #end
        # https://redmine.corp.halomonitor.com/issues/398
        # call to test_mode automatically logs the actions for user
        #user.test_mode( true) # Call Test Mode method to make caregivers away and opt senior out of SafetyCare
        user.log("Device (#{device.serial_number}) un-mapped from user (#{user.name})")
      end
      device.users = [] # Unmap users from devices, keep the device in the DB as an orphan
    end
  end
  
  # 
  #  Sat Nov 13 01:22:16 IST 2010, ramonrails
  #  fetch the device by serial number, id or instance
  # Usage
  #   Device.fetch_device( 'H200112233')
  #   Device.fetch_device( 123)
  #   Device.fetch_device( device)
  def self.fetch_device( _serial)
    if _serial.is_a?( Device)
      _serial
    elsif _serial.is_a?( String)
      Device.find_by_serial_number( _serial.strip)
    elsif _serial.to_i > 0
      Device.find_by_id( _serial.to_i)
    end
  end

  # ====================
  # = instance methods =
  # ====================
  
  # user intake with kit_serial_number of this device
  def user_intake
    # CHANGED: Sat Sep 25 00:56:19 IST 2010
    #   New logic is to fetch device.users.first.user_intakes.first_or_where_user_is_halouser
    # Assumption:
    #   user.devices count == 2
    #   user.gateways count == 1
    #   user.chest_straps count == 1
    #
    if !users.blank? && !users.first.user_intakes.blank?
      user = users.first # we need this variable in next line of code
      user.user_intakes.select {|e| user.is_halouser_of?( e) }.first # only pick halouser
    end
    #
    # CHANGED: Sat Sep 25 00:55:46 IST 2010
    #   Old logic was to find user intake by kit_serial_number
    #
    # UserIntake.find_by_kit_serial_number( serial_number)
  end
  
  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  def last_mgmt_query
    mgmt_queries.first( :order => "timestamp_server DESC") # fetch latest mgmt_query for this device
  end

  # check if dial_up_numbers are have "Ok" status for the given device
  # * mgmt_cmd row found for device having numbers (identified by cmd_type == dial_up_num_glob_prim)
  # * all 4 numbers are present
  # * local numbers cannot begin with "18"
  def dial_up_numbers_ok?
    # further logic is based on this mgmt_cmd row
    mgmt_cmd ||= mgmt_cmds.first(:conditions => ["cmd_type LIKE ?", "%dial_up_num_glob_prim%"], :order => "timestamp_sent DESC")
    unless ( failure = mgmt_cmd.blank? ) # mgmt_cmd row must exist
      numbers = (1..4).collect {|e| mgmt_cmd.send(:"param#{e}") } # collect global/local primary/secondary
      failure = numbers.any?(&:blank?) unless failure # the set of 4 numbers exist
      failure = numbers[0..1].collect {|e| e[0..1] == '18'}.include?( true) unless failure # local numbers (1,2) cannot start with "18"
    end
    !failure
  end

  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  def dial_up_alert_pending?
    # * last dial up alert does not exist. consider it resolved
    # * last dial up alert exists, check if resolved
    !last_dial_up_alert.blank? && !last_dial_up_alert.resolved?
  end

  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  def last_dial_up_alert
    attr_last_dial_up_alert ||= dial_up_alerts.first( :order => "created_at DESC")
  end

  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  def last_dial_up_failed?
    # WARNING: should the default status be assumed "not failed" when status is missing?
    # best guess is, consider all Ok, unless it fails
    last_dial_up_status.blank? ? false : last_dial_up_status.status.downcase.include?('fail')
  end
  
  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  def last_dial_up_status
    attr_last_dial_up_status ||= dial_up_statuses.first( :order => "created_at DESC")
  end
  
  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  # firmware software version for the device
  def software_version
    device_info.blank? ? "" : device_info.software_version
  end

  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  # is the firmware software version of device same as current?
  def current_software_version?
    software_version == FirmwareUpgrade.current_software_version
  end

  def device_type
    device_revision.device_model.device_type.device_type rescue ''
    # if device_revision && device_revision.device_model && device_revision.device_model.device_type
    #   return device_revision.device_model.device_type.device_type
    # else
    #   return ''
    # end
  end

  def device_type_object(device_type)
    if device_revision && device_revision.device_model && device_revision.device_model.device_type
      if device_revision.device_model.device_type.device_type == device_type
        return device_revision.device_model.device_type
      else
        return ''
      end
    else
      return ''
    end
  end

  def register_user
    if user = User.find_by_serial_number(self.serial_number)
      self.user_id = user.id
      self.save

      user.id
    end
  end

  def set_chest_strap_type

    self.check_serial_number
    if (self.serial_number[0].chr == 'H' and ( self.serial_number[1].chr == '1' or self.serial_number[1].chr == '5'))
      self.device_revision = find_device_revision(self)
    else
      raise "Invalid serial number for Halo Chest Straps and Belt Clips"
    end
  end

  def set_gateway_type
    self.check_serial_number
    if (self.serial_number[0].chr == 'H' and self.serial_number[1].chr == '2')
      self.device_revision = find_device_revision(self)
    else
      raise "Invalid serial number for Halo Gateway"
    end
  end

  def check_serial_number
    if (self.serial_number == nil || self.serial_number.length != 10)
      raise "Invalid serial number"
    end
  end

  def find_device_revision(device)
    if (device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
      return DeviceRevision.find(:first, :order => "device_types.id desc", :include => [{:device_model => :device_type}], :conditions => "device_types.device_type = 'Chest Strap'")
    elsif (device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
      return DeviceRevision.find(:first, :order => "device_types.id desc", :include => [{:device_model => :device_type}], :conditions => "device_types.device_type = 'Gateway'")
    elsif (device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '5')
      return DeviceRevision.find(:first, :order => "device_types.id desc", :include => [{:device_model => :device_type}], :conditions => "device_types.device_type = 'Belt Clip'")
    else
      return nil
    end
  end

  def set_type
    if (self.serial_number == nil)
      self.device_type = "Invalid serial num"
    elsif (self.serial_number.length != 10)
      self.device_type = "Invalid serial num"
    elsif (self.serial_number[0].chr == 'H' and self.serial_number[1].chr == '1')
      self.device_type = "Halo Chest Strap"
    elsif (self.serial_number[0].chr == 'H' and self.serial_number[1].chr == '2')
      self.device_type = "Halo Gateway"
    elsif (self.serial_number[0].chr == 'H' and self.serial_number[1].chr == '5')
      self.device_type = "Belt Clip"
    else
      self.device_type = "Unknown Device"
    end

    self.save
  end
  
end
