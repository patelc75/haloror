class Device < ActiveRecord::Base
  has_one :device_info
  has_many :mgmt_cmds
  has_many :mgmt_queries
  
  belongs_to :user
  
  def register_user
    if user = User.find_by_serial_number(self.serial_number)    
      self.user_id = user.id
      self.save
      
      user.id
    end
  end
end
