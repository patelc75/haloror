# Defines named roles for users that may be applied to
# objects in a polymorphic fashion. For example, you could create a role
# "moderator" for an instance of a model (i.e., an object), a model class,
# or without any specification at all.
class Role < ActiveRecord::Base
  # has_and_belongs_to_many :users
  has_many :roles_users
  has_many :users, :through => :roles_users, :include => [:roles_users]
  belongs_to :authorizable, :polymorphic => true
  #has_one :roles_user
  # class methods
  
  class << self
    def all_except(*args)
      args = args.flatten # do not use flatten!. it can return nil in some cases
      self.all(:select => "DISTINCT name").reject {|e| args.include?(e.name) } unless args.blank? # exclude all role names given in an array
    end
  end

  # instance methods
  
  # fetch options for specific user with this role id
  def options_for_user(user_or_id)
    user_id = (user_or_id.is_a?(User) ? user_or_id.id : user_or_id)
    RolesUser.find_by_user_id_and_role_id(user_id, self.id).roles_users_option
  end
end
