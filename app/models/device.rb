class Device < ActiveRecord::Base
  # attributes -------------------
  
  attr_accessor :attr_last_dial_up_status, :attr_last_dial_up_alert
  attr_accessor :cache_user_intake
  
  # relationships ------------------
  
  belongs_to :device_revision
  belongs_to :work_order

  has_one :access_mode_status
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

  # validations ----------------------
  
  validates_presence_of :serial_number
  validates_length_of :serial_number, :is => 10
  validates_uniqueness_of :serial_number, :case_sensitive => false

  # methods -----------------------

  # user intake with kit_serial_number of this device
  # cache for better performance
  def user_intake
    self.cache_user_intake ||= UserIntake.find_by_kit_serial_number( serial_number)
  end
  
  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  def last_mgmt_query
    mgmt_queries.first( :order => "timestamp_server DESC") # fetch latest mgmt_query for this device
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
