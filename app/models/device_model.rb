class DeviceModel < ActiveRecord::Base
  belongs_to :device_type
  has_many :device_revisions
  has_many :rma_items
  has_many :coupon_codes, :class_name => "DeviceModelPrice", :dependent => :destroy # just easier and DRY
  # validates_presence_of :part_number
  # validates_uniqueness_of :part_number
  named_scope :recent_on_top, :order => "created_at DESC"

  # =================
  # = class methods =
  # =================

  # fetch device_model for the product type "complete" or "clip"
  # no parameters = myHalo complete product
  # WARNING: this is a very risky method. static values should not be used.
  # Usage:
  #   DeviceModel.myhalo_clip, DeviceModel.myhalo_complete
  class << self # dynamic class methods
    ["clip", "complete"].each do |_which|
      #
      # device_model
      define_method "myhalo_#{_which}".to_sym do
        DeviceModel.find_by_part_number( _which == 'complete' ? '12001002-1' : '12001008-1')
      end
    end
  end # dynamic class methods

  # WARNING: this is a very risky method. static values should not be used.
  def self.find_complete_or_clip( name = "complete")
    #
    # Just call method DeviceModel.myhalo_complete or DeviceModel.myhalo_clip
    # Assumption:
    #   It has to be either 'clip' or 'complete', nothing else
    #   If it is not 'clip', assume 'complete'
    DeviceModel.send( "myhalo_#{ name == 'clip' ? name : 'complete'}".to_sym)
    #
    # old logic
    # _product_name = (name == "clip") ? "myHalo Clip": "myHalo Complete" # default = myHaloComplete
    # DeviceModel.find_by_part_number( OrderItem::PRODUCT_HASH[ _product_name ])
  end

  def self.complete_coupon( group, coupon_code)
    _product = DeviceModel.myhalo_complete
    if _product.blank?
      DeviceModelPrice.default( _product)
    else
      _product.coupon( :group => group, :coupon_code => coupon_code)
    end
  end
  
  def self.clip_coupon( group, coupon_code)
    _product = DeviceModel.myhalo_clip
    if _product.blank?
      DeviceModelPrice.default( _product)
    else
      _product.coupon( :group => group, :coupon_code => coupon_code)
    end
  end

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
  def coupon( options = {})
    # fetch coupon_code row when
    #   * options are not blank, is a hash, includes keys :group & :coupon_code
    #   * coupon_codes are not empty
    # Tue Nov  2 06:23:48 IST 2010
    #   logic updated:
    #   * first search for 'default' coupon code for the given group
    #   * next search for 'default' coupon code for 'default' group
    #   * none of the above found, return nil
    if ( !options.blank? && options.is_a?(Hash) && !options[:group].blank? && !coupon_codes.blank? )
      #
      # we do have coupon_codes available for this device_model
      _coupon = if options[:coupon_code].blank?
        #
        # 'default' coupon code for this group exists?
        coupon_codes.for_group( options[:group]).for_coupon_code( 'default').first
      else
        #
        # fetch given coupon code for 'default' group. we may find it
        coupon_codes.for_group( options[:group]).for_coupon_code( options[:coupon_code]).first
      end
    end
    #
    # nothing found, we must look for 'default' coupon code of 'default' group
    _coupon = DeviceModelPrice.default( self) if _coupon.blank?
    _coupon
  end
end