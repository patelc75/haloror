class DeviceRevision < ActiveRecord::Base
  has_many :work_orders
  belongs_to :device_model
  has_many :devices
  
  def revision_model_type
    return "#{self.revision} -- #{self.device_model.model} -- #{self.device_model.device_type.device_type}" if(self.device_model && self.device_model.device_type)
    return "#{self.revision} -- #{self.device_model.model}" if(self.device_model)
    return "#{self.revision}"
  end
end