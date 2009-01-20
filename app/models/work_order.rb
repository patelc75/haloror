class WorkOrder < ActiveRecord::Base
  has_many :devices
  has_many :device_revisions
  has_many :device_revisions_work_orders
  has_many :atp_test_results, :through => :atp_test_results_work_orders
end