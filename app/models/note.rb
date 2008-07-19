class Note < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
end
