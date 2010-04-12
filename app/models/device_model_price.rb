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
    months_advance.zero? ? months_trial : months_advance
  end
end
