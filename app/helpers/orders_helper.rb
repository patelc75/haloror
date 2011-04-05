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
  def selected_total_cost( _tariff, _order)
    if _tariff.blank?
      '?'
    else
      _charge = if _tariff.shipping.blank?
        if @shipping_option.blank?
          _tariff.upfront_charge
        else
          _tariff.upfront_charge + @shipping_option.price
        end
      else
        _tariff.upfront_charge
      end
      #   * apply dealer_install_fee charge only when checkbox "on"
      #   * omitting this charge from tariff requires more complex code. this is easier and simpler
      _charge -= _tariff.dealer_install_fee.to_i unless _order.dealer_install_fee_applies
      USD_value( _charge)
    end
  end
  
end
