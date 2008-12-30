class AtpTestResult < ActiveRecord::Base
  has_many :work_orders
  has_many :rmas
  has_many :atp_item_results
end