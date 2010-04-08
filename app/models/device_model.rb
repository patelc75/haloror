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

    # dynamically define complete_tariff, clip_traiff
    # usage:
    #   DeviceModel.complete_tariff [<coupon_code>] => default tariff, or based on coupon code
    ["complete", "clip"].each do |type|
      define_method("#{type}_tariff".to_sym) do |*coupon_code|
        product = find_complete_or_clip(type) # WARNING: find_complete_or_clip uses static values
        product.tariff(:coupon_code => coupon_code.flatten.first) unless product.blank?
      end
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
  
  # fetch related device_model_price record for "this" record, subject to coupon_code
  def tariff(options)
    options = {:coupon_code => "", :force_default => true}.merge(options)
    unless prices.blank?
      found = prices.recent_on_top.first(:conditions => {:coupon_code => options[:coupon_code]}) # find coupon code price
      # find default price if a valid coupon code price was not found
      found = prices.recent_on_top.first(:conditions => {:coupon_code => [nil, ""]}) \
        if (found.blank? && options[:force_default]) unless options[:coupon_code].blank?
    end
    found
  end
end