class ShippingOption < ActiveRecord::Base
  # 
  #  Wed Mar  9 01:02:09 IST 2011, ramonrails
  #   * coupon code changes for tickets #4253, #4067, #4060, #3923
  has_many :orders
  validates_presence_of :description
  validates_uniqueness_of :description
  named_scope :ordered, lambda {|*args| { :order => (args.flatten.first || 'description') } }
end
