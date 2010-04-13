class OrderItem < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  belongs_to :order
  belongs_to :device_model
  
  # FIXME: this should not be static!  but while it is, this should be in device class. Why here?
  PRODUCT_HASH = Hash[
   "myHalo Complete" => "12001002-1",
   "myHalo Clip"     => "12001008-1"
   ]
  
  # Retruns the product type based on device model or recurring charge
  # TODO: change the logic to use device_types table instead of hardcoding the label from @@products_hash
  def product_model
    # CHANGED: DRYed
    # if recurring_monthly; elsif device_model.blank?; else <device_name_and_part_number>
    recurring_monthly ? "Recurring Monthly" : \
      (device_model.blank? ? "Unknown" : \
        (PRODUCT_HASH.index(device_model.part_number) || '') + " (" + device_model.part_number + ")"
      )
    
    # part_num_hash = PRODUCT_HASH.invert
    # 
    # if(recurring_monthly == true)
    #   "Recurring Monthly"
    # else
    #   if !device_model.nil?
    #     label = part_num_hash[device_model.part_number] + " (" + device_model.part_number + ")" 
    #   else
    #     label = "Unknown"
    #   end
    # end
  end
  
  def status
    if(recurring_monthly == true)
      "Billing starts " + device_model.tariff(:coupon_code => order.coupon_code).recurring_delay.months.from_now.to_s(:day_date).to_s
    else
      "In Process"
    end
  end
  
  def formatted_cost(qty=nil)
    qty = 1 if qty == nil
    formatted_cost = number_to_currency(qty * cost, :precision => 2, :unit => '$')
    if(recurring_monthly == true)
      formatted_cost = formatted_cost.to_s + "/mo"
    end
    formatted_cost
  end
end
