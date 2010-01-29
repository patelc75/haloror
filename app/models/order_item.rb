class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :device_revision
  
  def product_model
    device_revision.revision_model_type
  end
  
  def calculated_cost
    quantity * cost
  end
end
