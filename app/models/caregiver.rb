class Caregiver < ActiveRecord::Base
  has_many :call_orders
  has_many :users, :through => :call_orders
end
