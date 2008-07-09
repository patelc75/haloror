class Note < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
end