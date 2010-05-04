class Group < ActiveRecord::Base
  acts_as_authorizable
  has_many :emergency_numbers
  has_many :recurring_charges
  has_many :rmas
  has_many :rma_items

  validates_format_of :name, :with => /\A[a-z0-9_]+\z/, :message => 'Only lowercase and numeric characters are allowed'
  
  # groups where user has "sales" or "admin" role
  #
  named_scope :for_sales_or_admin_user, lambda { |user| 
      group_ids = user.group_memberships.collect {|group| (user.is_sales_of?(group) || user.is_admin_of?(group)) ? group.id : nil }.compact
      { :conditions => {:id => group_ids} }
    }
  
  # groups applicable to user
  #
  def self.for_user(user)
    (user.class != "User") ? find(:all) : (user.is_super_admin? ? find(:all) : for_sales_or_admin_user(user))
  end
end