class ShippingOption < ActiveRecord::Base
  # 
  #  Thu Apr  7 00:14:19 IST 2011, ramonrails
  #   * required for USD_value
  include ApplicationHelper
  #   * for number_to_currency that is otherwise available from ActionView only
  include ActionView::Helpers::NumberHelper
  
  # 
  #  Wed Mar  9 01:02:09 IST 2011, ramonrails
  #   * coupon code changes for tickets #4253, #4067, #4060, #3923
  has_many :orders
  validates_presence_of :description
  validates_uniqueness_of :description
  named_scope :ordered, lambda {|*args| { :order => (args.flatten.first || 'description') } }
  
  def price_and_description
    "#{USD_value( price)} : #{description}"
  end
end
