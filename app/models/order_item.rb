class OrderItem < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  belongs_to :order
  belongs_to :device_revision
  
  def product_model
    if(recurring_monthly == true)
      "Recurring Monthly"
    else      
      if DeviceType.find_product_by_any_name("Halo Clip, Belt Clip")
        label = "myHalo Clip"
      elsif DeviceType.find_product_by_any_name("Halo Complete, Chest Strap")
        label = "myHalo Complete"        
      else
        label = "Unknown"
      end
      
      label = label + " (" + device_revision.revision_model + ")"
    end
  end
  
  def status
    if(recurring_monthly == true)
      "Billing starts " + 3.months.from_now.to_s(:day_date).to_s
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
