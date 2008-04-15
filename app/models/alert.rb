class Alert < ActiveRecord::Base
  belongs_to :roles_users_option
  include Priority
end
