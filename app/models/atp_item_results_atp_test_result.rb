class AtpItemResultsAtpTestResult < ActiveRecord::Base
  belongs_to :atp_item_result
  belongs_to :atp_test_result
end