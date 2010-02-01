class DeviceType < ActiveRecord::Base
  has_many :device_models
  has_many :serial_number_prefixes
  
  # find device by any name in given comma separated values
  # usage: find_product_bY_any_name("Halo Complete, Chest Strap")
  #
  def self.find_product_by_any_name(phrase)
    full_name = ""
    names = phrase.split(',').collect {|p| p.gsub(/^ +/,'').gsub(/ +$/,'') }
    names.each do |name|
      unless count(:conditions => {:device_type => name}).zero?
        full_name = find_by_device_type(name).latest_model_revision_name
        break
      end
    end
    full_name
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