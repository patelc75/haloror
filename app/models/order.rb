class Order < ActiveRecord::Base
  has_many :order_items
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  
  # order number : YYYYMMDD-id
  #
  def full_number
    "#{created_at.to_date.to_s(:number)}-#{id}"
  end
end
