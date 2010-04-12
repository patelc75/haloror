class DeviceRevision < ActiveRecord::Base
  has_many :work_orders, :through => :device_revisions_work_orders
  has_many :device_revisions_work_orders
  belongs_to :device_model
  has_one :device_type, :through => :device_model
  has_many :devices
  has_many :atp_items, :through => :atp_items_device_revisions
  has_many :atp_items_device_revisions
  has_many :order_items
  
  named_scope :online, :conditions => {:online_store => true}
  named_scope :recent_on_top, :order => 'created_at DESC'
  
  # class methods
  
  class << self
    # find first online revision that matches any comma separated device name
    # usage: find_by_device_names("Chest Strap, Halo Complete")
    #
    # TODO: can be refactored better as named_scope
    def find_by_device_names(phrase)
      found = nil
      device_types = DeviceType.find_all_names(phrase)
      recent_on_top.map do |revision|
        if device_types.include?( revision.device_type)
          found = revision
          break
        end
      end
      found
    end
  end
  
  # instance methods
  
  def revision_model
    return self.device_model ? "#{self.device_model.part_number}-#{self.revision}" : "#{self.revision}"
  end
  
  def revision_model_type
    return (self.device_model && self.device_model.device_type) ? \
      "#{self.device_model.device_type.device_type} #{self.device_model.part_number}-#{self.revision}" : \
      revision_model
  end
  
  # get device_type_name
  #
  def device_type_name
    device_type.blank? ? "" : device_type.device_type
  end
  
  # get device_type_id
  #
  def device_type_id
    device_type.blank? ? 0 : device_type.id
  end

  # device_type
  #
  def device_type
    device_model.device_type rescue nil
  end
end