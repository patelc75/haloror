class ShippingOption < ActiveRecord::Base
  # 
  #  Wed Mar  9 01:02:09 IST 2011, ramonrails
  #   * coupon code changes for tickets #4253, #4067, #4060, #3923
  belongs_to :order
end
