# Defines named roles for users that may be applied to
# objects in a polymorphic fashion. For example, you could create a role
# "moderator" for an instance of a model (i.e., an object), a model class,
# or without any specification at all.
class Role < ActiveRecord::Base
  #has_and_belongs_to_many :users
  has_many :roles_users
  has_many :users, :through => :roles_users, :include => [:roles_users]
  
  belongs_to :authorizable, :polymorphic => true
  
  #has_one :roles_user
end
