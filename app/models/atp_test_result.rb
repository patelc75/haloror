class AtpTestResult < ActiveRecord::Base
  has_many :work_orders, :through => :atp_test_results_work_orders
  has_many :rmas, :through => :atp_test_results_rmas
  has_many :atp_item_results, :through => :atp_item_results_atp_test_results
end