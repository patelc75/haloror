class OrderItem < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  belongs_to :order
  belongs_to :device_model
  
  # FIXME: this should not be static!  but while it is, this should be in device class. Why here?
  # WARNING: do not change anything in this hash. lot of code is depenent on this
  # 
  #  Fri Nov  5 02:09:54 IST 2010, ramonrails
  #   shift the logic to use serial numbers instead of product names. check device_model for more details
  #   alternate: DeviceModel.myhalo_complete, DeviceModel.myhalo_clip
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
      #{}"Billing starts " + device_model.coupon( :group => (order.group || Group.direct_to_consumer), :coupon_code => order.coupon_code).recurring_delay.months.from_now.to_s(:day_date).to_s
      "A prorated charge will occur when the system is installed or 7 days after the sytem has shipped, whichever comes first.\nThe monthly recurring will begin the 1st day of the month AFTER the prorated charge."
    else
      "In Process"
    end
  end
  
  def formatted_cost( qty = nil)
    # qty = 1 if qty == nil
    # formatted_cost = number_to_currency(qty * cost, :precision => 2, :unit => '$')
    # if(recurring_monthly == true)
    #   formatted_cost = formatted_cost.to_s + "/mo"
    # end
    # formatted_cost
    # 
    #  Fri Nov  5 02:07:14 IST 2010, ramonrails
    #  same logic as above. DRY
    number_to_currency( (qty || 1) * cost, :precision => 2, :unit => '$').to_s + ( recurring_monthly ? '/mo' : '')
  end
end
