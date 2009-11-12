class Kit < ActiveRecord::Base
  has_and_belongs_to_many :devices
  
  def check_for_device_type(device_type)
    self.devices.each do |device|
      if device.device_type == device_type
        return device
      end
    end
    return false
  end
  
end