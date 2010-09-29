class DeviceType < ActiveRecord::Base
  has_many :device_models
  has_many :serial_number_prefixes
  # validates_presence_of :device_type
  # validates_uniqueness_of :device_type
  
  named_scope :find_all_names, lambda { |phrase| 
    names = phrase.split(',').collect(&:strip);
    {
      :conditions => {:device_type => names}
    }
  }
  
  # class methods
  #
  class << self
    # find device by any name in given comma separated values
    # usage: find_product_by_any_name("Halo Complete, Chest Strap")
    #
    def find_product_by_any_name(phrase)
      device = nil
      names = phrase.split(',').collect(&:strip)
      names.each do |name|
        unless count(:conditions => {:device_type => name}).zero?
          device = find_by_device_type(name)
          break
        end
      end
      device
    end
  end

  # instance methods
  #
  
  # find latest revision of latest model
  # TODO: change the logic to pick up device_revisions instead of device_type
  #
  def latest_model_revision
    unless device_models.length.zero?
      device_model = device_models.last
      unless device_model.device_revisions.length.zero?
        device_revision = device_model.device_revisions.last
      end
    end
  end
  
  # latest revision of latest model will be picked
  # TODO: should we have online_store flag on device_revisions table?
  #       device_revisions can also have various price values associated to them
  #
  def latest_model_revision_name
    name = device_type
    if device_models.length > 0
      last_model = device_models.last
      name += " #{last_model.part_number}"
      if last_model.device_revisions.length > 0
        name += " #{last_model.device_revisions.last.revision}"
      end
    end
  end
  
end