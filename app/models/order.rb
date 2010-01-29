class Order < ActiveRecord::Base
  has_many :order_items
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :creator, :class_name => 'User', :foreign_key => 'updated_by'
end
