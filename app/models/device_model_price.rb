class DeviceModelPrice < ActiveRecord::Base
  # =============
  # = relations =
  # =============
  belongs_to :device_model
  belongs_to :group
  
  # ===============
  # = validations =
  # ===============
  
  # 
  #  Sat Feb  5 00:36:47 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4103
  validates_presence_of :expiry_date, :deposit, :shipping, :monthly_recurring, :months_advance, :months_trial, :dealer_install_fee
  validates_presence_of :group, :coupon_code, :device_model # https://redmine.corp.halomonitor.com/issues/3542
  validates_each :expiry_date do |model, attr, value|
    model.errors.add( 'Expiry date must be at least one day in future.') if value.blank? || (value < Date.tomorrow)
  end
  
  # https://redmine.corp.halomonitor.com/issues/3562
  # one coupon_code per device_model per group
  validates_uniqueness_of :coupon_code, :scope => [:device_model_id, :group_id]
  
  # ======================
  # = filters and scopes =
  # ======================
  
  named_scope :recent_on_top, :order => "created_at DESC"
  named_scope :for_group, lambda {|_group| { :conditions => { :group_id => _group.id } }} # used in device_model.rb
  named_scope :for_coupon_code, lambda {|arg| { :conditions => { :coupon_code => arg.to_s } }}
  named_scope :for_device_model, lambda {|_device| { :conditions => { :device_model_id => _device.id } }} # used in group.rb
  named_scope :contains, lambda {|*args|
    _str = "%#{args.flatten.first}%"
    _num = args.flatten.first.to_i
    _conditions = if _num.zero?
      ["coupon_code LIKE ? OR device_models.part_number LIKE ? OR groups.name LIKE ?", _str, _str, _str]
    else
      ["coupon_code LIKE ? OR device_models.part_number LIKE ? OR groups.name LIKE ? OR deposit = ? OR shipping = ? OR monthly_recurring = ? OR months_advance = ? OR months_trial = ?", _str, _str, _str, _num, _num, _num, _num, _num]
    end
    { :joins => "LEFT OUTER JOIN groups ON device_model_prices.group_id = groups.id LEFT OUTER JOIN device_models ON device_model_prices.device_model_id = device_models.id", :conditions => _conditions }
    }

  # =============
  # = callbacks =
  # =============

  # 
  #  Mon Feb 21 22:36:17 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4226#note-5
  # def after_initialize
  #   self.group ||= Group.direct_to_consumer
  # end

  # =================
  # = class methods =
  # =================
  
  # WARNING: Sat Sep 18 00:11:16 IST 2010
  #   * Double check the default values
  # CHANGED: business logic changed. default group now has default coupon codes
  #   * now searches by part number instead of product phrase
  # Usage: returns default coupon code for...
  #   default( DeviceModel.myhalo_clip.part_number )     => myhalo_clip
  #   default( DeviceModel.myhalo_complete.part_number ) => myhalo_complete
  #   default( DeviceModel.myhalo_clip )                 => myhalo_clip
  #   default( DeviceModel.myhalo_complete )             => myhalo_complete
  #   default( DeviceModel.first.part_number )           => myhalo_complete, unless this row is a valid myhalo_clip
  #   default                                            => myhalo_complete
  #   default( "bogus-part-number")                      => myhalo_complete
  def self.default( arg = nil)
    _model = if arg.blank?
      DeviceModel.myhalo_complete
    elsif arg.is_a?( DeviceModel)
      (arg == DeviceModel.myhalo_clip) ? DeviceModel.myhalo_clip : DeviceModel.myhalo_complete
    else
      (arg.to_s == DeviceModel.myhalo_clip.part_number) ? DeviceModel.myhalo_clip : DeviceModel.myhalo_complete
    end
    _model.coupon_codes.first( :conditions => { :coupon_code => 'default', :group_id => Group.default! })
  end
  
  # =================
  # = class methods =
  # =================

  # 
  #  Tue Jan 11 01:22:02 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3988
  def self.collection_for_selection
    self.all.collect { |e| ["#{e.group_name} : #{e.part_number} : #{e.device_type} : #{e.coupon_code}", e.id] }
  end

  # ====================
  # = instance methods =
  # ====================
  
  def group_name
    group.blank? ? Group.direct_to_consumer.name : group.name
  end

  def group_name=(name)
    self.group = Group.find_by_name( name)
  end
  
  def device_model_part_number=( _number)
    self.device_model = DeviceModel.find_by_part_number( _number)
  end
  
  def device_model_type=( name)
    self.device_model = DeviceModel.find_complete_or_clip( name)
  end
  
  def part_number
    device_model.blank? ? '' : device_model.part_number
  end
  
  def device_type
    (device_model.blank? || device_model.device_type.blank?) ? '' : device_model.device_type.device_type
  end
  
  def advance_charge
    monthly_recurring.to_i * months_advance.to_i
  end
  
  def upfront_charge
    advance_charge.to_i + deposit.to_i + shipping.to_i + dealer_install_fee.to_i
  end
  
  def discounted
    monthly_recurring.to_i * months_trial.to_i
  end
  
  def recurring_delay
    # * payment taken for advance_months, or, trial_months should delay subscription by those many months
    # * we either accept advance or give trial, never both
    # * future compatibility
    #   * advance "and" trial can co-exist
    #   * this logic holds good for existing business logic of advance "or" trial
    months_advance.to_i + months_trial.to_i # delay for advance taken + trial given
    # months_advance.zero? ? months_trial : months_advance # old logic for advance "or" trial
  end
  
  def expired?
    expiry_date.blank? ? false : (expiry_date < Date.today)
  end
end
