class DeviceModelPrice < ActiveRecord::Base
  # =============
  # = relations =
  # =============
  belongs_to :device_model
  belongs_to :group
  
  # ===============
  # = validations =
  # ===============
  
  validates_presence_of :group, :coupon_code, :device_model # https://redmine.corp.halomonitor.com/issues/3542
  # https://redmine.corp.halomonitor.com/issues/3562
  # one coupon_code per device_model per group
  validates_uniqueness_of :coupon_code, :scope => [:device_model_id, :group_id]
  
  # ======================
  # = filters and scopes =
  # ======================
  
  named_scope :recent_on_top, :order => "created_at DESC"
  named_scope :for_group, lambda {|group| { :conditions => { :group_id => group.id } }}
  named_scope :for_coupon_code, lambda {|arg| { :conditions => { :coupon_code => arg } }}
  
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
    monthly_recurring * months_advance
  end
  
  def upfront_charge
    advance_charge + deposit + shipping
  end
  
  def discounted
    monthly_recurring * months_trial
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
