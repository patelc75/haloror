class Device < ActiveRecord::Base
  has_one :device_info
  has_many :mgmt_cmds
  has_many :mgmt_queries
  
  has_many :battery_charge_completes
  has_many :battery_criticals
  has_many :battery_pluggeds
  has_many :battery_unpluggeds
  has_many :strap_fasteneds
  has_many :strap_removeds
  has_many :device_unavailable_alerts
  has_many :device_available_alerts
  has_many :gateway_offline_alerts
  has_many :gateway_online_alerts
  has_many :batteries
  
  has_and_belongs_to_many :users
  
  validates_presence_of     :serial_number
  validates_length_of       :serial_number, :is => 10
  
  validates_uniqueness_of   :serial_number, :case_sensitive => false
  
  def register_user
    if user = User.find_by_serial_number(self.serial_number)    
      self.user_id = user.id
      self.save
      
      user.id
    end
  end
  
  def set_type
    if(self.serial_number == nil)
      self.device_type = "Invalid serial num"
    elsif(self.serial_number.length != 10)
      self.device_type = "Invalid serial num"
    elsif(self.serial_number[0].chr == 'H' and self.serial_number[1].chr == '1')
      self.device_type = "Halo Chest Strap"
    elsif(self.serial_number[0].chr == 'H' and self.serial_number[1].chr == '2')
      self.device_type = "Halo Gateway"
    else
      self.device_type = "Unknown Device"
    end
    
    self.save
  end
end
