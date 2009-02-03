class DeviceRevision < ActiveRecord::Base
  has_many :work_orders, :through => :device_revisions_work_orders
  has_many :device_revisions_work_orders
  belongs_to :device_model
  has_many :devices
  has_many :atp_items, :through => :atp_items_device_revisions
  has_many :atp_items_device_revisions
  
  def revision_model_type
    return "#{self.revision} -- #{self.device_model.part_number} -- #{self.device_model.device_type.device_type}" if(self.device_model && self.device_model.device_type)
    return "#{self.revision} -- #{self.device_model.part_number}" if(self.device_model)
    return "#{self.revision}"
  end
end