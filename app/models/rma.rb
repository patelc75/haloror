class Rma < ActiveRecord::Base
  has_many :atp_test_results, :through => :atp_test_results_rmas
  belongs_to :group
  belongs_to :user
end