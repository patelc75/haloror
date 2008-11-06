class AtpItemResult < ActiveRecord::Base
  belongs_to :atp_item
  has_many :atp_test_results, :through => :atp_item_results_atp_test_results
end