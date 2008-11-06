class AtpTestResultsWorkOrder < ActiveRecord::Base
  belongs_to :work_order
  belongs_to :atp_test_result
end