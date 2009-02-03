class DeviceModel < ActiveRecord::Base
  belongs_to :device_type
  has_many :device_revisions
  
  def model_type
    return "#{self.part_number} -- #{self.device_type.device_type}" if(self.device_type)
    return "#{self.part_number}"
  end
end