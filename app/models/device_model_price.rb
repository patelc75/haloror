class DeviceModelPrice < ActiveRecord::Base
  belongs_to :device_model
  named_scope :recent_on_top, :order => "created_at DESC"
  
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
    months_advance + months_trial # delay for advance taken + trial given
    # months_advance.zero? ? months_trial : months_advance # old logic for advance "or" trial
  end
  
  def expired?
    expiry_date.blank? ? false : (expiry_date < Date.today)
  end
end
