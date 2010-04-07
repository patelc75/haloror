class DeviceModel < ActiveRecord::Base
  belongs_to :device_type
  has_many :device_revisions
  has_many :rma_items
  has_many :prices, :class_name => "DeviceModelPrice" # just easier and DRY
  named_scope :recent_on_top, :order => "created_at DESC"

  # class methods
  
  class << self
    #
    # fetch device_model for the product type "complete" or "clip"
    # no parameters = myHalo complete product
    # WARNING: this is a very risky method. static values should not be used.
    def find_complete_or_clip(name = "complete")
      product_string = (name == "clip") ? "myHalo Clip": "myHalo Complete" # default = myHaloComplete
      DeviceModel.recent_on_top.find_by_part_number(OrderItem::PRODUCT_HASH[product_string])
    end
  end
  
  # instance methods
  
  def model_type
    return "#{self.part_number} -- #{self.device_type.device_type}" if(self.device_type)
    return "#{self.part_number}"
  end
  
  def latest_revision
    device_revisions.reent_on_top.first # (:order => "created_at DESC")
  end
  
  def default_tariff
    prices.recent_on_top.first(:conditions => {:coupon_code => [nil, ""]}) unless prices.blank?
  end
end