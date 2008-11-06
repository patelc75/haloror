class AtpTestResultsRma < ActiveRecord::Base
  belongs_to :rma
  belongs_to :atp_test_result
end