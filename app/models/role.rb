# Defines named roles for users that may be applied to
# objects in a polymorphic fashion. For example, you could create a role
# "moderator" for an instance of a model (i.e., an object), a model class,
# or without any specification at all.
class Role < ActiveRecord::Base
  # has_and_belongs_to_many :users # not suggested in roles_authorization plugin
  has_many :roles_users, :dependent => :delete_all # WARNING: do not touch this association
  has_many :users, :through => :roles_users # WARNING: do not touch this association
  belongs_to :authorizable, :polymorphic => true
  #has_one :roles_user
  named_scope :ordered, lambda {|*args| {:order => (args.flatten.first || "name ASC" )}}
  named_scope :distinct_by_name, :select => "DISTINCT name", :order => "name"
  named_scope :where_authorizable, lambda {|_type, _ids| { :conditions => { :authorizable_type => _type, :authorizable_id => _ids } }}

  # class methods

  def self.all_distinct_names_except(*args)
    # "names" must be returned in all cases
    # distinct_names are returned if nothing is excluded
    # names must be ordered always
    args = args.flatten # do not use flatten!. it can return nil in some cases
    names = distinct_by_name.ordered.reject {|e| args.include?(e.name) } unless args.blank? # exclude all role names given in an array
    # names.sort {|x,y| x.name <=> y.name } # better to sort in database than memory
    names
  end

  def self.user_ids
    users.collect(&:id)
  end

  # instance methods

  # fetch options for specific user with this role id
  def options_for_user(user_or_id)
    user_id = (user_or_id.is_a?(User) ? user_or_id.id : user_or_id)
    RolesUser.find_by_user_id_and_role_id(user_id, self.id).roles_users_option
  end
end
