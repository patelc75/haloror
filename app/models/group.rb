class Group < ActiveRecord::Base
  acts_as_authorizable
  has_many :emergency_numbers
  has_many :recurring_charges
  has_many :rmas
  has_many :rma_items
  has_many :orders
  has_many :roles, :as => :authorizable
  named_scope :distinct_by_name, :select => "DISTINCT name, *", :order => "name ASC"

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
    user.is_a?(User) ? (user.is_super_admin? ? find(:all) : for_sales_or_admin_user(user)) : find(:all)
  end
  
  def users
    # all users having any role for this group
    # Usage:
    #   group.users
    users_of_roles(roles)
  end
  
  def users_with_role(role = nil)
    # all users having specific role in the group
    # Usage:
    #   group.users_with_role("admin")
    #   group.users_with_role(["admin", "sales"])
    users_of_roles(roles(:conditions => {:name => role}))
  end
  
  private # -----------------------------
  
  def users_of_roles(roles)
    roles.blank? ? [] : roles.collect(&:users).flatten.uniq # return an array in all cases
  end
  
end