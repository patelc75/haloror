class DeviceModel < ActiveRecord::Base
  belongs_to :device_type
  has_many :device_revisions
  has_many :rma_items
  has_many :prices, :class_name => "DeviceModelPrice" # just easier and DRY
  named_scope :recent_on_top, :order => "created_at DESC"

  # class methods
  
  #
  # fetch device_model for the product type "complete" or "clip"
  # no parameters = myHalo complete product
  # WARNING: this is a very risky method. static values should not be used.
  def self.find_complete_or_clip(name = "complete")
    product_string = (name == "clip") ? "myHalo Clip": "myHalo Complete" # default = myHaloComplete
    DeviceModel.find_by_part_number(OrderItem::PRODUCT_HASH[product_string])
  end

  # dynamically define self.complete_tariff, self.clip_traiff
  #
  class << self
    # usage:
    #   DeviceModel.complete_tariff [<coupon_code>] => default tariff, or based on coupon code
    ["complete", "clip"].each do |type|
      define_method("#{type}_tariff".to_sym) do |group, *coupon_code|
        product = find_complete_or_clip(type) # WARNING: find_complete_or_clip uses static values
        product.tariff( :group => group, :coupon_code => coupon_code.flatten.first) unless product.blank?
      end
    end
  end
  
  # instance methods
  
  def model_type
    return "#{self.part_number} -- #{self.device_type.device_type}" if(self.device_type)
    return "#{self.part_number}"
  end
  
  def latest_revision
    device_revisions.recent_on_top.first # (:order => "created_at DESC")
  end
  
  # fetch related device_model_price record for "this" record, subject to coupon_code
  def tariff(args = {})
    unless args[:group].blank?
      options = {:coupon_code => "default", :force_default => true}.merge(args)
      unless prices.blank?
        found = prices.for_group( options[:group]).first(:conditions => { :coupon_code => options[:coupon_code]}) # find coupon code price
        #
        # WARNING: This can be very costly to business since this is dependent on data
        #   * ensure default price exists
        #   * we must send some email to admin/other when such rows are created
        # find default price if a valid coupon code price was not found
        if (found.blank? && options[:force_default])
          group = if options[:group].is_a?( String)
            Group.find_by_name( options[:group])
          elsif options[:group].is_a?( Integer) || options[:group].is_a?( Fixnum)
            Group.find( options[:group].to_i)
          else
            options[:group]
          end
          found = group.default_coupon_code  #  && !options[:coupon_code].blank?
          # found = prices.for_group( options[:group]).first(:conditions => { :coupon_code => [nil, "", "default"]}) if (found.blank? && options[:force_default]) #  && !options[:coupon_code].blank?
        end
      end
    end
    found
  end
end