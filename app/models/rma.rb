class Rma < ActiveRecord::Base
  has_many :atp_test_results, :through => :atp_test_results_rmas
  has_many :rma_items
  belongs_to :group
  belongs_to :user
  validates_presence_of :serial_number
  ["user_id", "serial_number", "status"].each do |which|
    named_scope "for_#{which}".to_sym, lambda { |arg| {:conditions => {"#{which}".to_sym => arg} }}
  end
  
  # methods for views
  #
  def user_name; return (user.blank? ? '' : user.name); end
  def user_name=(name); user = User.find_by_login(name); end
  def group_name; return (group.blank? ? '' : group.name); end
  def group_name=(name); group = Group.find_by_name(name); end
end