class Event < ActiveRecord::Base
  belongs_to :user
  acts_as_authorizable
end
