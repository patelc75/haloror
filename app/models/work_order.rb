class WorkOrder < ActiveRecord::Base
  has_many :device_types, :through => :device_types_work_orders, :include => :device_types_work_order
  has_many :device_types_work_orders
  has_many :atp_test_results, :through => :atp_test_results_work_orders
end