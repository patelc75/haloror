module OrdersHelper
  
  def default_tariff(product = "complete")
    product = "complete" unless product == "clip" # explicitly "clip", all other cases "complete"
  end

end
