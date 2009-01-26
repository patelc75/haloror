class AtpItemResult < ActiveRecord::Base
  belongs_to :atp_item
  belongs_to :atp_test_results
end