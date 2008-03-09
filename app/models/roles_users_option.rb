class RolesUsersOption < ActiveRecord::Base
  belongs_to :role
  has_many :alerts
end
