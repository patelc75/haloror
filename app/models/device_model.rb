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
    _product.coupon( :group => group, :coupon_code => coupon_code) || DeviceModelPrice.default( _product)
  end
  
  def self.clip_coupon( group, coupon_code)
    _product = DeviceModel.myhalo_clip
    _product.coupon( :group => group, :coupon_code => coupon_code) || DeviceModelPrice.default( _product)
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
    if ( !options.blank? && options.is_a?(Hash) && !options[:group].blank? && !options[:coupon_code].blank? && !coupon_codes.blank? )
      _coupon = coupon_codes.for_group( options[:group]).for_coupon_code( options[:coupon_code]).first
    end
    _coupon = DeviceModelPrice.default( self) if ( !defined?(_coupon) || _coupon.blank? )
    _coupon
  end
end