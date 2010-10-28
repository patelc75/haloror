class DeviceModel < ActiveRecord::Base
  belongs_to :device_type
  has_many :device_revisions
  has_many :rma_items
  has_many :prices, :class_name => "DeviceModelPrice", :dependent => :destroy # just easier and DRY
  # validates_presence_of :part_number
  # validates_uniqueness_of :part_number
  named_scope :recent_on_top, :order => "created_at DESC"

  # =================
  # = class methods =
  # =================

  #
  # fetch device_model for the product type "complete" or "clip"
  # no parameters = myHalo complete product
  # WARNING: this is a very risky method. static values should not be used.
  def self.find_complete_or_clip(name = "complete")
    product_string = (name == "clip") ? "myHalo Clip": "myHalo Complete" # default = myHaloComplete
    DeviceModel.find_by_part_number(OrderItem::PRODUCT_HASH[product_string])
  end

  def self.complete_tariff( group, coupon_code)
    debugger
    tariff( :device_model => find_complete_or_clip( 'complete'), :group => group, :coupon_code => coupon_code)
  end

  def self.clip_tariff( group, coupon_code)
    debugger
    tariff( :device_model => find_complete_or_clip( 'clip'), :group => group, :coupon_code => coupon_code)
  end
  
  # # dynamically define self.complete_tariff, self.clip_traiff
  # #
  # class << self
  #   # usage:
  #   #   DeviceModel.complete_tariff [<coupon_code>] => default tariff, or based on coupon code
  #   ["complete", "clip"].each do |type|
  #     define_method("#{type}_tariff".to_sym) do |group, coupon_code|
  #       product = find_complete_or_clip(type) # WARNING: find_complete_or_clip uses static values
  #       debugger
  #       product.tariff( :device_model => product, :group => group, :coupon_code => coupon_code) unless product.blank?
  #     end
  #   end
  # end

  # ====================
  # = instance methods =
  # ====================

  def device_type_name=( name)
    self.device_type = DeviceType.find_by_device_type( name)
  end

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
      debugger
      options = {:coupon_code => "default"}.merge(args)
      unless prices.blank?
        #
        # TODO: Need validation fix for DeviceType and DeviceModel
        #   https://redmine.corp.halomonitor.com/issues/3468
        #
        # Done for now on existing scenarios. Check again for newer scenarios
        found = DeviceModelPrice.for_group( options[:group]).for_coupon_code( options[:coupon_code]).first # find coupon code price
        #
        # WARNING: This can be very costly to business since this is dependent on data
        #   * ensure default price exists
        #   * we must send some email to admin/other when such rows are created
        # find default price if a valid coupon code price was not found
        if found.blank?
          group = if options[:group].is_a?( String)
            Group.find_by_name( options[:group])
          elsif options[:group].is_a?( Integer) || options[:group].is_a?( Fixnum)
            Group.find( options[:group].to_i)
          else
            options[:group]
          end
          found = group.default_coupon_code( self.device_type.device_type)  #  && !options[:coupon_code].blank?
          # found = prices.for_group( options[:group]).first(:conditions => { :coupon_code => [nil, "", "default"]}) if (found.blank? && options[:force_default]) #  && !options[:coupon_code].blank?
        end
      end
    end
    found
  end
end