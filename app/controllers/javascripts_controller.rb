class JavascriptsController < ApplicationController
  def shipping_options
    @shipping_options = ShippingOption.ordered( "price ASC")
  end
end
