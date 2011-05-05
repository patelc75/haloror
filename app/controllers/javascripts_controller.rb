class JavascriptsController < ApplicationController
  layout false # no layout require here. we are just generating javascript files
  before_filter :js_content_type # HTTP header
  
  def js_content_type
    response.headers['Content-type'] = 'text/javascript; charset=utf-8'
  end
  
  def shipping_options
    @shipping_options = ShippingOption.ordered( "price ASC")
  end
end
