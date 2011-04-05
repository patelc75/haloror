module OrdersHelper
  
  def default_tariff(product = "complete")
    product = "complete" unless product == "clip" # explicitly "clip", all other cases "complete"
  end

  # 
  #  Mon Apr  4 23:02:31 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4318
  def selected_shipping_option( _tariff)
     if _tariff.blank? 
      '?'
     else 
       if _tariff.shipping.blank? 
         if @shipping_option.blank? 
          'Select above'
         else 
          USD_value( @shipping_option.price) 
         end 
       else 
        USD_value( _tariff.shipping) 
       end 
     end 
  end

  # 
  #  Mon Apr  4 23:02:39 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4318
  def selected_total_cost( _tariff)
    if _tariff.blank?
      '?'
    else
      if _tariff.shipping.blank?
        if @shipping_option.blank?
          USD_value( _tariff.upfront_charge)
        else
          USD_value( _tariff.upfront_charge + @shipping_option.price)
        end
      else
        USD_value( _tariff.upfront_charge)
      end
    end
  end
  
end
