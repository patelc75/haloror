class SelfTestResult < ActiveRecord::Base
  has_many :self_test_item_results
end