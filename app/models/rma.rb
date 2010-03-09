class Rma < ActiveRecord::Base
  has_many :atp_test_results, :through => :atp_test_results_rmas
  has_many :rma_items
  belongs_to :group
  belongs_to :user
    
  # methods for views
  #
  def user_name; return (user.blank? ? '' : user.name) ; end
  def group_name; return (group.blank? ? '' : group.name) ; end
end