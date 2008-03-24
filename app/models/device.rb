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
  has_many :outage_alerts
  
  belongs_to :user
  
  validates_presence_of     :serial_number
  validates_length_of       :serial_number, :is => 10
  
  def register_user
    if user = User.find_by_serial_number(self.serial_number)    
      self.user_id = user.id
      self.save
      
      user.id
    end
  end
end
